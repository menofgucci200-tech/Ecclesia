@extends('admin.layouts.app')

@section('title', 'Configuration des paiements')
@section('heading', 'Configuration des paiements')
@section('subheading', 'Vos identifiants CinetPay — les fonds arrivent directement sur votre compte')

@section('content')
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div class="lg:col-span-2">
            <form method="POST" action="{{ admin_route('payment-settings.update') }}" class="space-y-6">
                @csrf @method('PUT')

                <div class="card card-pad">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-base font-bold">Compte CinetPay</h3>
                        @if($parish->hasCinetPay())
                            <span class="badge-success">● Paiements activés</span>
                        @else
                            <span class="badge-gold">Non configuré</span>
                        @endif
                    </div>

                    <div class="space-y-5">
                        <div>
                            <label class="field-label" for="cinetpay_site_id">Site ID</label>
                            <input id="cinetpay_site_id" name="cinetpay_site_id" type="text"
                                   value="{{ old('cinetpay_site_id', $parish->cinetpay_site_id) }}"
                                   class="input" placeholder="Ex. 105XXXX">
                            <p class="field-hint">Identifiant du site marchand (visible dans votre back-office CinetPay).</p>
                            @error('cinetpay_site_id') <p class="field-error">{{ $message }}</p> @enderror
                        </div>

                        <div>
                            <label class="field-label" for="cinetpay_api_key">Clé API (API Key)</label>
                            <input id="cinetpay_api_key" name="cinetpay_api_key" type="text" autocomplete="off"
                                   class="input font-mono"
                                   placeholder="{{ $parish->cinetpay_api_key ? '•••••••• (enregistrée — laisser vide pour conserver)' : 'Collez votre clé API' }}">
                            @error('cinetpay_api_key') <p class="field-error">{{ $message }}</p> @enderror
                        </div>

                        <div>
                            <label class="field-label" for="cinetpay_secret_key">Clé secrète (Secret Key)</label>
                            <input id="cinetpay_secret_key" name="cinetpay_secret_key" type="text" autocomplete="off"
                                   class="input font-mono"
                                   placeholder="{{ $parish->cinetpay_secret_key ? '•••••••• (enregistrée — laisser vide pour conserver)' : 'Collez votre clé secrète' }}">
                            <p class="field-hint">Vos clés sont stockées chiffrées et ne sont jamais réaffichées.</p>
                            @error('cinetpay_secret_key') <p class="field-error">{{ $message }}</p> @enderror
                        </div>
                    </div>
                </div>

                <div class="card card-pad">
                    <h3 class="mb-4 text-base font-bold">Demandes de messe</h3>
                    <div>
                        <label class="field-label" for="mass_offering_amount">Offrande de messe par défaut (F CFA)</label>
                        <input id="mass_offering_amount" name="mass_offering_amount" type="number" min="0" step="100"
                               value="{{ old('mass_offering_amount', $parish->mass_offering_amount) }}" class="input" placeholder="3000">
                        <p class="field-hint">Montant proposé par défaut au fidèle. Laisser vide = 3 000 F CFA.</p>
                        @error('mass_offering_amount') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div class="flex items-center justify-end gap-3">
                    <button type="submit" class="btn-primary">
                        <x-icon name="check" class="h-4 w-4" /> Enregistrer
                    </button>
                </div>
            </form>
        </div>

        {{-- Help sidebar --}}
        <div class="space-y-4">
            <div class="card card-pad">
                <h3 class="mb-2 flex items-center gap-2 text-base font-bold">
                    <x-icon name="credit-card" class="h-5 w-5 text-[color:var(--color-navy)]" /> Comment ça marche
                </h3>
                <ol class="list-decimal space-y-2 pl-4 text-sm text-[color:var(--color-ink-soft)]">
                    <li>Créez et faites valider votre compte marchand sur <span class="font-semibold">cinetpay.com</span>.</li>
                    <li>Dans CinetPay : <em>Intégrations → API</em>, copiez votre <span class="font-semibold">Site ID</span> et votre <span class="font-semibold">API Key</span>.</li>
                    <li>Collez-les ici, puis enregistrez.</li>
                    <li>Les paiements des fidèles (quêtes, dons, messes…) arrivent <span class="font-semibold">directement</span> sur votre compte.</li>
                </ol>
            </div>
            <div class="card card-pad">
                <p class="text-xs text-[color:var(--color-ink-soft)]">
                    Ecclesia ne détient jamais vos fonds : chaque paroisse encaisse sur son propre compte CinetPay et
                    suit ses transactions dans son espace CinetPay.
                </p>
            </div>
        </div>
    </div>
@endsection
