@php
    /** @var \App\Models\ParishEvent $event */
    $isEdit = $event->exists;
    $startsValue = old('starts_at', optional($event->starts_at)->format('Y-m-d\TH:i'));
    $endsValue = old('ends_at', optional($event->ends_at)->format('Y-m-d\TH:i'));
@endphp

<form method="POST" enctype="multipart/form-data"
      action="{{ $isEdit ? admin_route('events.update', $event) : admin_route('events.store') }}"
      class="mx-auto max-w-3xl space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif

    <div class="card card-pad space-y-5">
        <div>
            <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
            <input id="title" name="title" type="text" value="{{ old('title', $event->title) }}" class="input" required>
            @error('title') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div>
                <label class="field-label" for="starts_at">Début <span class="text-red-500">*</span></label>
                <input id="starts_at" name="starts_at" type="datetime-local" value="{{ $startsValue }}" class="input" required>
                @error('starts_at') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="ends_at">Fin (optionnel)</label>
                <input id="ends_at" name="ends_at" type="datetime-local" value="{{ $endsValue }}" class="input">
                @error('ends_at') <p class="field-error">{{ $message }}</p> @enderror
            </div>
        </div>
        <div>
            <label class="field-label" for="location">Lieu</label>
            <input id="location" name="location" type="text" value="{{ old('location', $event->location) }}" class="input" placeholder="Église, salle paroissiale…">
            @error('location') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="field-label" for="description">Description</label>
            <textarea id="description" name="description" class="textarea" rows="5">{{ old('description', $event->description) }}</textarea>
            @error('description') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="field-label" for="image">Image (optionnel)</label>
            @if($event->image)
                <img src="{{ \Illuminate\Support\Facades\Storage::url($event->image) }}" alt="" class="mb-2 h-24 rounded-xl object-cover">
            @endif
            <input id="image" name="image" type="file" accept="image/png,image/jpeg,image/webp"
                   class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white">
            @error('image') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm">
            <input type="hidden" name="is_published" value="0">
            <input type="checkbox" name="is_published" value="1" @checked(old('is_published', $event->is_published ?? true)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
            <span><span class="font-medium">Publié</span> (visible dans l'application)</span>
        </label>
    </div>

    <div class="flex items-center justify-end gap-3">
        <a href="{{ admin_route('events.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary"><x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer' }}</button>
    </div>
</form>
