@php
    /** @var \App\Models\Movement $movement */
    $isEdit = $movement->exists;
    $adminLogin = old('login', $movement->admin?->username);
@endphp

<form method="POST" enctype="multipart/form-data"
      action="{{ $isEdit ? admin_route('movements.update', $movement) : admin_route('movements.store') }}"
      class="mx-auto max-w-3xl space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif

    <div class="card card-pad space-y-5">
        <h3 class="text-base font-bold">Le mouvement</h3>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div class="sm:col-span-2">
                <label class="field-label" for="name">Nom du mouvement <span class="text-red-500">*</span></label>
                <input id="name" name="name" type="text" value="{{ old('name', $movement->name) }}" class="input" required placeholder="Chorale Sainte-Cécile, Légion de Marie…">
                @error('name') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="category">Catégorie</label>
                <input id="category" name="category" type="text" value="{{ old('category', $movement->category) }}" class="input" placeholder="Chorale, Prière, Jeunesse…">
                @error('category') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="meeting_info">Réunions</label>
                <input id="meeting_info" name="meeting_info" type="text" value="{{ old('meeting_info', $movement->meeting_info) }}" class="input" placeholder="Samedi 16h, salle 2">
                @error('meeting_info') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div class="sm:col-span-2">
                <label class="field-label" for="description">Description</label>
                <textarea id="description" name="description" class="textarea" rows="4">{{ old('description', $movement->description) }}</textarea>
                @error('description') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div class="sm:col-span-2">
                <label class="field-label" for="logo">Logo</label>
                @if($movement->logo)
                    <img src="{{ \Illuminate\Support\Facades\Storage::url($movement->logo) }}" alt="" class="mb-2 h-16 w-16 rounded-xl object-cover">
                @endif
                <input id="logo" name="logo" type="file" accept="image/png,image/jpeg,image/webp"
                       class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white">
                @error('logo') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm sm:col-span-2">
                <input type="hidden" name="is_active" value="0">
                <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $movement->is_active ?? true)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                <span><span class="font-medium">Actif</span> (visible par les fidèles dans l'application)</span>
            </label>
        </div>
    </div>

    <div class="card card-pad space-y-5">
        <div class="flex items-center gap-2">
            <h3 class="text-base font-bold">Accès responsable</h3>
            <span class="badge-navy">Dashboard du mouvement</span>
        </div>
        <p class="text-sm text-[color:var(--color-ink-soft)]">Le responsable se connectera sur <span class="font-mono">/mouvement</span> avec ces identifiants pour gérer les annonces, documents et membres.</p>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div>
                <label class="field-label" for="login">Login @if(!$isEdit)<span class="text-red-500">*</span>@endif</label>
                <input id="login" name="login" type="text" value="{{ $adminLogin }}" class="input" autocorrect="off" spellcheck="false" @if(!$isEdit) required @endif>
                @error('login') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="password">Mot de passe @if(!$isEdit)<span class="text-red-500">*</span>@endif</label>
                <input id="password" name="password" type="text" value="" class="input" placeholder="{{ $isEdit ? 'Laisser vide pour ne pas changer' : 'Au moins 6 caractères' }}" @if(!$isEdit) required @endif>
                @error('password') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
    </div>

    <div class="flex items-center justify-end gap-3">
        <a href="{{ admin_route('movements.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary"><x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer le mouvement' }}</button>
    </div>
</form>
