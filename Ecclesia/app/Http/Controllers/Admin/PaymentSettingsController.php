<?php

declare(strict_types=1);

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Parish;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * Lets a parish administrator enter its own CinetPay merchant credentials, so
 * payments made by its faithful are credited directly to the parish.
 */
class PaymentSettingsController extends Controller
{
    public function edit(Request $request): View
    {
        $parish = $this->parish($request);

        return view('admin.payment-settings.edit', compact('parish'));
    }

    public function update(Request $request): RedirectResponse
    {
        $parish = $this->parish($request);

        $data = $request->validate([
            'cinetpay_site_id' => ['nullable', 'string', 'max:255'],
            'cinetpay_api_key' => ['nullable', 'string', 'max:2000'],
            'cinetpay_secret_key' => ['nullable', 'string', 'max:2000'],
            'mass_offering_amount' => ['nullable', 'integer', 'min:0', 'max:100000000'],
        ]);

        $parish->mass_offering_amount = $data['mass_offering_amount'] ?? null;

        // Site ID isn't secret: it is prefilled, so save it as-is (blank clears
        // and disables payments). API/secret keys are write-only: a blank field
        // keeps the stored value, a filled one replaces it.
        $parish->cinetpay_site_id = $data['cinetpay_site_id'] ?: null;
        if (! empty($data['cinetpay_api_key'])) {
            $parish->cinetpay_api_key = $data['cinetpay_api_key'];
        }
        if (! empty($data['cinetpay_secret_key'])) {
            $parish->cinetpay_secret_key = $data['cinetpay_secret_key'];
        }
        $parish->save();

        return back()->with('success', 'Paramètres de paiement enregistrés.');
    }

    private function parish(Request $request): Parish
    {
        $parishId = $request->user()->managedParishId();
        abort_if($parishId === null, 403, 'Espace réservé aux administrateurs de paroisse.');

        return Parish::findOrFail($parishId);
    }
}
