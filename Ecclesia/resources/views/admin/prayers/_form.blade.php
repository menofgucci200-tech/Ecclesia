@php
    /** @var \App\Models\Prayer $prayer */
    $isEdit = $prayer->exists;
@endphp

<form method="POST" enctype="multipart/form-data" action="{{ $isEdit ? admin_route('prayers.update', $prayer) : admin_route('prayers.store') }}" class="grid grid-cols-1 gap-6 lg:grid-cols-3">
    @csrf
    @if($isEdit) @method('PUT') @endif

    {{-- Main column --}}
    <div class="space-y-6 lg:col-span-2">
        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Contenu</h3>
            <div class="space-y-5">
                <div>
                    <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
                    <input id="title" name="title" type="text" value="{{ old('title', $prayer->title) }}" class="input" required placeholder="Ex. Je vous salue Marie">
                    @error('title') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="subtitle">Sous-titre</label>
                    <input id="subtitle" name="subtitle" type="text" value="{{ old('subtitle', $prayer->subtitle) }}" class="input" placeholder="Ex. Prière mariale">
                    @error('subtitle') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="body">Texte <span class="text-red-500">*</span></label>
                    <textarea id="body" name="body" class="textarea" rows="18" required placeholder="Saisissez le texte complet…">{{ old('body', $prayer->body) }}</textarea>
                    <p class="field-hint">Les sauts de ligne sont conservés tels quels dans l'application.</p>
                    @error('body') <p class="field-error">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>

        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Image (optionnel)</h3>
            <div class="flex items-center gap-5">
                <div class="flex h-24 w-24 shrink-0 items-center justify-center overflow-hidden rounded-xl border border-[color:var(--color-border-soft)] bg-[color:var(--color-surface-muted)]">
                    @if($prayer->image)
                        <img src="{{ \Illuminate\Support\Facades\Storage::url($prayer->image) }}" alt="illustration" class="h-full w-full object-cover">
                    @else
                        <x-icon name="heart" class="h-8 w-8 text-[color:var(--color-ink-faint)]" />
                    @endif
                </div>
                <div class="flex-1">
                    <input id="image" name="image" type="file" accept="image/png,image/jpeg,image/webp"
                           class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white hover:file:bg-[color:var(--color-navy-dark)]">
                    <p class="field-hint">Une illustration affichée en tête dans l'application. PNG, JPG ou WebP — 4 Mo max.</p>
                    @error('image') <p class="field-error">{{ $message }}</p> @enderror
                </div>
            </div>
        </div>
    </div>

    {{-- Sidebar column --}}
    <div class="space-y-6">
        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Classement</h3>
            <div class="space-y-5">
                <div>
                    <label class="field-label" for="category">Catégorie <span class="text-red-500">*</span></label>
                    <select id="category" name="category" class="select" required>
                        @foreach($categories as $c)
                            <option value="{{ $c->value }}" @selected(old('category', $prayer->category?->value) === $c->value)>{{ $c->label() }}</option>
                        @endforeach
                    </select>
                    @error('category') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="reference">Référence / source</label>
                    <input id="reference" name="reference" type="text" value="{{ old('reference', $prayer->reference) }}" class="input" placeholder="Ex. Missel romain">
                    @error('reference') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="position">Ordre d'affichage</label>
                    <input id="position" name="position" type="number" min="0" value="{{ old('position', $prayer->position ?? 0) }}" class="input">
                    <p class="field-hint">Plus petit = affiché en premier.</p>
                    @error('position') <p class="field-error">{{ $message }}</p> @enderror
                </div>

                <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm">
                    <input type="hidden" name="is_published" value="0">
                    <input type="checkbox" name="is_published" value="1" @checked(old('is_published', $prayer->is_published)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                    <span><span class="font-medium">Publié</span> — visible dans l'application</span>
                </label>
            </div>
        </div>

        <div class="flex items-center justify-end gap-3">
            <a href="{{ admin_route('prayers.index') }}" class="btn-ghost">Annuler</a>
            <button type="submit" class="btn-primary">
                <x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer' }}
            </button>
        </div>
    </div>
</form>
