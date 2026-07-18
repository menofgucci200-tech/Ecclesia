@php
    /** @var \App\Models\Parish $parish */
    $isEdit = $parish->exists;
@endphp

<form method="POST" action="{{ $isEdit ? admin_route('parishes.update', $parish) : admin_route('parishes.store') }}" class="space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif

    <div class="card card-pad">
        <h3 class="mb-4 text-base font-bold">Identité</h3>
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
                <label class="field-label" for="diocese">Diocèse <span class="text-red-500">*</span></label>
                <input id="diocese" name="diocese" type="text" value="{{ old('diocese', $parish->diocese) }}" class="input" required>
                @error('diocese') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    <div class="card card-pad">
        <h3 class="mb-4 text-base font-bold">Localisation</h3>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
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
        <a href="{{ admin_route('parishes.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary">
            <x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer la paroisse' }}
        </button>
    </div>
</form>
