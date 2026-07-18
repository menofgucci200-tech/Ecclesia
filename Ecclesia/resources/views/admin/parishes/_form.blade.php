@php
    /** @var \App\Models\Parish $parish */
    $isEdit = $parish->exists;
    $adminLogin = old('login', $parish->admin?->username);
@endphp

<form method="POST" enctype="multipart/form-data"
      action="{{ $isEdit ? route('super.parishes.update', $parish) : route('super.parishes.store') }}" class="space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif

    {{-- ============ Identité & accès (obligatoire) ============ --}}
    <div class="card card-pad">
        <div class="mb-4 flex items-center gap-2">
            <h3 class="text-base font-bold">Identité & accès</h3>
            <span class="badge-navy">Obligatoire</span>
        </div>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div class="sm:col-span-2">
                <label class="field-label" for="name">Nom de la paroisse <span class="text-red-500">*</span></label>
                <input id="name" name="name" type="text" value="{{ old('name', $parish->name) }}" class="input" required>
                @error('name') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="code">Code <span class="text-red-500">*</span></label>
                <input id="code" name="code" type="text" value="{{ old('code', $parish->code) }}" class="input font-mono uppercase" required>
                <p class="field-hint">Identifiant unique (ex. STJEANCOCODY).</p>
                @error('code') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="subscription_amount">Abonnement annuel (F CFA) <span class="text-red-500">*</span></label>
                <input id="subscription_amount" name="subscription_amount" type="number" min="0" step="50"
                       value="{{ old('subscription_amount', $parish->subscription_amount ?? 2000) }}" class="input" required>
                <p class="field-hint">Montant payé par chaque fidèle. Défaut : 2 000 F CFA.</p>
                @error('subscription_amount') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="login">Login administrateur @if(!$isEdit)<span class="text-red-500">*</span>@endif</label>
                <input id="login" name="login" type="text" value="{{ $adminLogin }}" class="input"
                       autocorrect="off" spellcheck="false" @if(!$isEdit) required @endif>
                <p class="field-hint">Sert à la paroisse pour se connecter à son espace (sans espace).</p>
                @error('login') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="password">Mot de passe @if(!$isEdit)<span class="text-red-500">*</span>@endif</label>
                <input id="password" name="password" type="text" value="" class="input"
                       placeholder="{{ $isEdit ? 'Laisser vide pour ne pas changer' : 'Au moins 6 caractères' }}"
                       @if(!$isEdit) required @endif>
                <p class="field-hint">Communiquez-le à la paroisse. Modifiable à tout moment.</p>
                @error('password') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    {{-- ============ Logo (optionnel) ============ --}}
    <div class="card card-pad">
        <div class="mb-4 flex items-center gap-2">
            <h3 class="text-base font-bold">Logo</h3>
            <span class="badge-muted">Optionnel</span>
        </div>
        <div class="flex items-center gap-5">
            <div class="flex h-20 w-20 shrink-0 items-center justify-center overflow-hidden rounded-xl border border-[color:var(--color-border-soft)] bg-[color:var(--color-surface-muted)]">
                @if($parish->logo)
                    <img src="{{ \Illuminate\Support\Facades\Storage::url($parish->logo) }}" alt="logo" class="h-full w-full object-cover">
                @else
                    <x-icon name="church" class="h-8 w-8 text-[color:var(--color-ink-faint)]" />
                @endif
            </div>
            <div class="flex-1">
                <input id="logo" name="logo" type="file" accept="image/png,image/jpeg,image/webp"
                       class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-[color:var(--color-navy-dark)]">
                <p class="field-hint">PNG, JPG ou WebP — 2 Mo max.</p>
                @error('logo') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    {{-- ============ Localisation (optionnel) ============ --}}
    <div class="card card-pad">
        <div class="mb-4 flex items-center gap-2">
            <h3 class="text-base font-bold">Localisation & diocèse</h3>
            <span class="badge-muted">Optionnel</span>
        </div>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div class="sm:col-span-2">
                <label class="field-label" for="diocese">Diocèse</label>
                <input id="diocese" name="diocese" type="text" value="{{ old('diocese', $parish->diocese) }}" class="input">
                @error('diocese') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div class="sm:col-span-2">
                <label class="field-label" for="address">Adresse</label>
                <input id="address" name="address" type="text" value="{{ old('address', $parish->address) }}" class="input">
                @error('address') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="commune">Commune</label>
                <input id="commune" name="commune" type="text" value="{{ old('commune', $parish->commune) }}" class="input">
                @error('commune') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="city">Ville</label>
                <input id="city" name="city" type="text" value="{{ old('city', $parish->city) }}" class="input">
                @error('city') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="region">Région</label>
                <input id="region" name="region" type="text" value="{{ old('region', $parish->region) }}" class="input">
                @error('region') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="country">Pays</label>
                <input id="country" name="country" type="text" value="{{ old('country', $parish->country ?? 'Côte d\'Ivoire') }}" class="input">
                @error('country') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    {{-- ============ Contact & statut ============ --}}
    <div class="card card-pad">
        <h3 class="mb-4 text-base font-bold">Contact & statut</h3>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div>
                <label class="field-label" for="phone">Téléphone</label>
                <input id="phone" name="phone" type="text" value="{{ old('phone', $parish->phone) }}" class="input" placeholder="+225…">
                @error('phone') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="email">E-mail</label>
                <input id="email" name="email" type="email" value="{{ old('email', $parish->email) }}" class="input">
                @error('email') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="status">Statut <span class="text-red-500">*</span></label>
                <select id="status" name="status" class="select" required>
                    @foreach(\App\Enums\ParishStatus::cases() as $s)
                        <option value="{{ $s->value }}" @selected(old('status', $parish->status?->value) === $s->value)>{{ $s->label() }}</option>
                    @endforeach
                </select>
                <p class="field-hint">Seules les paroisses actives sont visibles dans l'application.</p>
                @error('status') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    <div class="flex items-center justify-end gap-3">
        <a href="{{ route('super.parishes.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary">
            <x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer la paroisse' }}
        </button>
    </div>
</form>
