<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Parish;
use App\Models\Payment;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Thin client for the CinetPay checkout API (Mobile Money & cards for West
 * Africa). Credentials are **per parish** — each parish holds its own CinetPay
 * merchant account, so funds go straight to the parish and Ecclesia never
 * holds any money. Runs in a graceful "not configured" state for a parish
 * until that parish enters its keys.
 *
 * @see https://docs.cinetpay.com
 */
class CinetPayService
{
    public function isConfiguredFor(?Parish $parish): bool
    {
        return $parish !== null && filled($parish->cinetpay_site_id) && filled($parish->cinetpay_api_key);
    }

    /**
     * Initialise a transaction against the parish's CinetPay account and return
     * the hosted payment URL the app must open.
     *
     * @param  array<string, string|null>  $customer
     */
    public function initialize(Payment $payment, Parish $parish, array $customer): string
    {
        if (! $this->isConfiguredFor($parish)) {
            throw new RuntimeException('CINETPAY_NOT_CONFIGURED');
        }

        $payload = [
            'apikey' => $parish->cinetpay_api_key,
            'site_id' => $parish->cinetpay_site_id,
            'transaction_id' => $payment->reference,
            'amount' => $payment->amount,
            'currency' => $payment->currency,
            'description' => $payment->label.' — '.$parish->name,
            'notify_url' => url('/api/payments/cinetpay/notify'),
            'return_url' => (string) config('services.cinetpay.return_url'),
            'channels' => 'ALL',
            'lang' => 'fr',
            'metadata' => $payment->reference,
            'customer_name' => $customer['name'] ?? 'Fidèle',
            'customer_surname' => $customer['surname'] ?? '',
            'customer_email' => $customer['email'] ?? 'fidele@ecclesia.app',
            'customer_phone_number' => $customer['phone'] ?? '',
            'customer_address' => 'Paroisse',
            'customer_city' => 'Abidjan',
            'customer_country' => 'CI',
            'customer_state' => 'CI',
            'customer_zip_code' => '00225',
        ];

        $response = Http::acceptJson()
            ->timeout(30)
            ->post($this->baseUrl().'/payment', $payload);

        $data = $response->json();

        if (($data['code'] ?? null) !== '201' || empty($data['data']['payment_url'])) {
            Log::warning('CinetPay init failed', ['reference' => $payment->reference, 'response' => $data]);
            throw new RuntimeException('CINETPAY_INIT_FAILED');
        }

        $payment->update([
            'cinetpay_token' => $data['data']['payment_token'] ?? null,
            'payment_url' => $data['data']['payment_url'],
        ]);

        return $data['data']['payment_url'];
    }

    /**
     * Ask CinetPay for the authoritative status of a transaction, using the
     * parish's credentials.
     *
     * @return array{status: string, channel: ?string, operator: ?string, raw: array<string, mixed>}
     */
    public function verify(string $reference, Parish $parish): array
    {
        if (! $this->isConfiguredFor($parish)) {
            throw new RuntimeException('CINETPAY_NOT_CONFIGURED');
        }

        $response = Http::acceptJson()
            ->timeout(30)
            ->post($this->baseUrl().'/payment/check', [
                'apikey' => $parish->cinetpay_api_key,
                'site_id' => $parish->cinetpay_site_id,
                'transaction_id' => $reference,
            ]);

        $data = $response->json();
        $inner = $data['data'] ?? [];

        $accepted = ($data['code'] ?? null) === '00' && ($inner['status'] ?? null) === 'ACCEPTED';

        return [
            'status' => $accepted ? 'ACCEPTED' : (string) ($inner['status'] ?? 'PENDING'),
            'channel' => $inner['payment_method'] ?? null,
            'operator' => $inner['operator_id'] ?? null,
            'raw' => is_array($data) ? $data : [],
        ];
    }

    private function baseUrl(): string
    {
        return rtrim((string) config('services.cinetpay.base_url'), '/');
    }
}
