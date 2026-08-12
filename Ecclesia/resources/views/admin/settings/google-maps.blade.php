@extends('admin.layouts.app')

@section('title', 'Google Maps')
@section('heading', 'Google Maps')
@section('subheading', "Clé d'API utilisée par « Découvrir » dans l'app et la recherche d'adresse dans ce tableau de bord")

@section('content')
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div class="lg:col-span-2">
            <form method="POST" action="{{ admin_route('settings.google-maps.update') }}" class="space-y-6">
                @csrf @method('PUT')

                <div class="card card-pad">
                    <div class="mb-4 flex items-center justify-between">
                        <h3 class="text-base font-bold">Clé API Google Maps</h3>
                        @if($hasKey)
                            <span class="badge-success">● Configurée</span>
                        @else
                            <span class="badge-gold">Non configurée</span>
                        @endif
                    </div>

                    <div>
                        <label class="field-label" for="google_maps_api_key">Clé API</label>
                        <input id="google_maps_api_key" name="google_maps_api_key" type="text" autocomplete="off"
                               class="input font-mono"
                               placeholder="{{ $hasKey ? '•••••••• (enregistrée — laisser vide pour conserver)' : 'Collez votre clé API Google Maps' }}">
                        <p class="field-hint">
                            Stockée chiffrée, jamais réaffichée. Utilisée pour le géocodage des adresses, la recherche
                            de lieu à la création d'une paroisse, et la carte dans l'application mobile.
                        </p>
                        @error('google_maps_api_key') <p class="field-error">{{ $message }}</p> @enderror
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
                    <x-icon name="location" class="h-5 w-5 text-[color:var(--color-navy)]" /> Comment obtenir une clé
                </h3>
                <ol class="list-decimal space-y-2 pl-4 text-sm text-[color:var(--color-ink-soft)]">
                    <li>Créez un projet sur <span class="font-semibold">console.cloud.google.com</span> et activez la facturation (carte requise, un crédit mensuel gratuit est offert).</li>
                    <li>Activez ces API : <span class="font-semibold">Maps SDK for Android</span>, <span class="font-semibold">Maps SDK for iOS</span>, <span class="font-semibold">Geocoding API</span>, <span class="font-semibold">Places API</span>.</li>
                    <li>Créez une clé API (<em>Identifiants → Créer des identifiants → Clé API</em>).</li>
                    <li>Restreignez-la aux 4 API ci-dessus (recommandé, évite les abus).</li>
                    <li>Collez-la ici, puis enregistrez.</li>
                </ol>
            </div>
            <div class="card card-pad">
                <p class="text-xs text-[color:var(--color-ink-soft)]">
                    Sans clé configurée, le géocodage des paroisses continue de fonctionner via OpenStreetMap
                    (gratuit) en attendant — mais la carte « Découvrir » de l'application et l'auto-complétion
                    d'adresse ci-dessous nécessitent cette clé.
                </p>
            </div>
        </div>
    </div>
@endsection
