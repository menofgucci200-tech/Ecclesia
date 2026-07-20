@php
    /** @var \App\Models\MovementPost $post */
    $isEdit = $post->exists;
    $publishedValue = old('published_at', optional($post->published_at)->format('Y-m-d\TH:i'));
@endphp
<form method="POST" enctype="multipart/form-data"
      action="{{ $isEdit ? route('mouvement.posts.update', $post) : route('mouvement.posts.store') }}"
      class="mx-auto max-w-3xl space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif
    <div class="card card-pad space-y-5">
        <div>
            <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
            <input id="title" name="title" type="text" value="{{ old('title', $post->title) }}" class="input" required>
            @error('title') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="field-label" for="body">Message <span class="text-red-500">*</span></label>
            <textarea id="body" name="body" class="textarea" rows="7" required>{{ old('body', $post->body) }}</textarea>
            @error('body') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="field-label" for="image">Image (optionnel)</label>
            @if($post->image)<img src="{{ \Illuminate\Support\Facades\Storage::url($post->image) }}" class="mb-2 h-24 rounded-xl object-cover" alt="">@endif
            <input id="image" name="image" type="file" accept="image/png,image/jpeg,image/webp" class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white">
            @error('image') <p class="field-error">{{ $message }}</p> @enderror
        </div>
        <div>
            <label class="field-label" for="published_at">Date de publication</label>
            <input id="published_at" name="published_at" type="datetime-local" value="{{ $publishedValue }}" class="input">
            <p class="field-hint">Laisser vide pour un brouillon.</p>
        </div>
    </div>
    <div class="flex items-center justify-end gap-3">
        <a href="{{ route('mouvement.posts.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary"><x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Publier' }}</button>
    </div>
</form>
