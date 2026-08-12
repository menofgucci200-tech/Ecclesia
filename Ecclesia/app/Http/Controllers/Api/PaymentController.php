<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Enums\MassIntentionType;
use App\Enums\PaymentStatus;
use App\Enums\PaymentType;
use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Payment;
use App\Services\CinetPayService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rules\Enum;
use RuntimeException;

class PaymentController extends Controller
{
    public function __construct(private readonly CinetPayService $cinetpay)
    {
    }

    /** Catalogue of payment types + parish, used to render the app forms. */
    public function options(Request $request): JsonResponse
    {
        $user = $request->user();
        $parish = $user->parish;

        return response()->json([
            'configured' => $this->cinetpay->isConfiguredFor($parish),
            'currency' => (string) config('services.cinetpay.currency', 'XOF'),
            'parish' => $parish?->only(['id', 'name']),
            'types' => collect(PaymentType::cases())->map(fn (PaymentType $t) => [
                'type' => $t->value,
                'label' => $t->label(),
                'description' => $t->description(),
                'is_mass_request' => $t->isMassRequest(),
                'suggested_amounts' => $t->suggestedAmounts(),
                'default_amount' => $t->isMassRequest()
                    ? ($parish?->massOfferingAmount() ?? 3000)
                    : $t->defaultAmount(),
                'date_label' => $t->dateLabel(),
            ])->values(),
            'mass_intention_types' => collect(MassIntentionType::cases())->map(fn (MassIntentionType $t) => [
                'value' => $t->value,
                'label' => $t->label(),
            ])->values(),
        ]);
    }

    /** Create a payment and hand back the CinetPay checkout URL. */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type' => ['required', new Enum(PaymentType::class)],
            'amount' => ['required', 'integer', 'min:100'],
            'note' => ['nullable', 'string', 'max:500'],
            // Optional date attached to any payment (mass date, quête Sunday…).
            'date' => ['nullable', 'date', 'after_or_equal:today'],
            // Mass-intention fields (required only for mass requests).
            'intention_type' => ['nullable', new Enum(MassIntentionType::class)],
            'intention' => ['nullable', 'string', 'max:500'],
        ]);

        $type = PaymentType::from($validated['type']);
        // CinetPay requires XOF amounts to be a multiple of 5.
        $amount = (int) (ceil($validated['amount'] / 5) * 5);

        if ($type->isMassRequest() && empty($validated['intention'])) {
            return response()->json([
                'message' => 'Veuillez préciser l\'intention de la messe.',
                'errors' => ['intention' => ['L\'intention est obligatoire.']],
            ], 422);
        }

        $user = $request->user();
        $parish = $user->parish;

        if ($parish === null) {
            return response()->json([
                'message' => 'Rejoignez d\'abord une paroisse pour effectuer un paiement.',
            ], 422);
        }

        $payment = Payment::create([
            'reference' => Payment::generateReference(),
            'parish_id' => $user->parish_id,
            'user_id' => $user->id,
            'type' => $type,
            'label' => $type->label(),
            'amount' => $amount,
            'currency' => (string) config('services.cinetpay.currency', 'XOF'),
            'status' => PaymentStatus::Pending,
            'meta' => [
                'note' => $validated['note'] ?? null,
                // Non-mass payments keep their date here (mass uses mass_date).
                'scheduled_for' => $type->isMassRequest() ? null : ($validated['date'] ?? null),
            ],
        ]);

        try {
            $url = $this->cinetpay->initialize($payment, $parish, [
                'name' => $user->first_name,
                'surname' => $user->last_name,
                'email' => $user->email,
                'phone' => $user->phone,
            ]);
        } catch (RuntimeException $e) {
            // Nothing was charged; drop the placeholder so it doesn't linger.
            $payment->delete();

            $message = $e->getMessage() === 'CINETPAY_NOT_CONFIGURED'
                ? 'Votre paroisse n\'a pas encore activé les paiements en ligne.'
                : 'Impossible de démarrer le paiement pour le moment. Veuillez réessayer.';

            return response()->json(['message' => $message], 503);
        }

        if ($type->isMassRequest()) {
            $payment->massIntention()->create([
                'parish_id' => $user->parish_id,
                'user_id' => $user->id,
                'intention_type' => $validated['intention_type'] ?? MassIntentionType::Autre->value,
                'intention' => $validated['intention'],
                'mass_date' => $validated['date'] ?? null,
                'note' => $validated['note'] ?? null,
                'amount' => $amount,
                'status' => 'pending',
            ]);
        }

        return response()->json([
            'reference' => $payment->reference,
            'payment_url' => $url,
            'status' => $payment->status->value,
        ], 201);
    }

    /** Poll a payment status (refreshes from CinetPay while still pending). */
    public function show(Request $request, string $reference): JsonResponse
    {
        $payment = Payment::where('reference', $reference)
            ->where('user_id', $request->user()->id)
            ->with(['massIntention', 'parish'])
            ->firstOrFail();

        if ($payment->status === PaymentStatus::Pending && $this->cinetpay->isConfiguredFor($payment->parish)) {
            $this->refresh($payment);
        }

        return response()->json(['payment' => new PaymentResource($payment->fresh('massIntention'))]);
    }

    /** The faithful's payment history. */
    public function mine(Request $request): JsonResponse
    {
        $payments = Payment::where('user_id', $request->user()->id)
            ->with('massIntention')
            ->latest()
            ->limit(100)
            ->get();

        return response()->json(['payments' => PaymentResource::collection($payments)]);
    }

    /** Lightweight landing page CinetPay redirects the browser to after paying. */
    public function returnPage(): \Illuminate\Http\Response
    {
        $html = <<<'HTML'
<!doctype html><html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Paiement Ecclesia</title>
<style>
  body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:#16335B;color:#fff;
       display:flex;min-height:100vh;align-items:center;justify-content:center;text-align:center;padding:24px}
  .card{max-width:420px}
  .badge{width:72px;height:72px;border-radius:50%;background:#C6A02C;display:flex;align-items:center;justify-content:center;
         margin:0 auto 20px;font-size:38px}
  h1{font-size:22px;margin:0 0 10px} p{opacity:.85;line-height:1.6;font-size:15px}
</style></head>
<body><div class="card">
  <div class="badge">✓</div>
  <h1>Merci !</h1>
  <p>Votre opération a été prise en compte.<br>Vous pouvez fermer cette page et revenir à l'application Ecclesia&nbsp;: le statut s'y mettra à jour automatiquement.</p>
</div></body></html>
HTML;

        return response($html)->header('Content-Type', 'text/html');
    }

    /** CinetPay server-to-server notification (public, no auth). */
    public function notify(Request $request): JsonResponse
    {
        $reference = $request->input('cpm_trans_id', $request->input('transaction_id'));

        if ($reference) {
            $payment = Payment::where('reference', $reference)->first();
            if ($payment && $payment->status === PaymentStatus::Pending) {
                $this->refresh($payment);
            }
        }

        // Always 200 so CinetPay stops retrying.
        return response()->json(['received' => true]);
    }

    /** Re-check a transaction with CinetPay and persist the outcome. */
    private function refresh(Payment $payment): void
    {
        if (! $this->cinetpay->isConfiguredFor($payment->parish)) {
            return;
        }

        try {
            $result = $this->cinetpay->verify($payment->reference, $payment->parish);
        } catch (RuntimeException $e) {
            Log::warning('CinetPay verify failed', ['reference' => $payment->reference, 'error' => $e->getMessage()]);

            return;
        }

        if ($result['status'] === 'ACCEPTED') {
            $payment->markPaid($result['channel'], $result['operator']);
        } elseif (in_array($result['status'], ['REFUSED', 'CANCELLED'], true)) {
            $payment->update(['status' => PaymentStatus::Failed]);
        }
    }
}
