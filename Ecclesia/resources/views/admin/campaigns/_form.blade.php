@php
    /** @var \App\Models\Campaign $campaign */
    $isEdit = $campaign->exists;
    $types = ['don' => 'Don', 'cotisation' => 'Cotisation', 'quete' => 'Quête'];
@endphp
<form method="POST" enctype="multipart/form-data"
      action="{{ $isEdit ? admin_route('campaigns.update', $campaign) : admin_route('campaigns.store') }}"
      class="mx-auto max-w-3xl space-y-6">
    @csrf
    @if($isEdit) @method('PUT') @endif
    <div class="card card-pad space-y-5">
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
            <div class="sm:col-span-2">
                <label class="field-label" for="title">Titre <span class="text-red-500">*</span></label>
                <input id="title" name="title" type="text" value="{{ old('title', $campaign->title) }}" class="input" required placeholder="Rénovation de l'autel…">
                @error('title') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="type">Type <span class="text-red-500">*</span></label>
                <select id="type" name="type" class="select" required>
                    @foreach($types as $val => $lbl)
                        <option value="{{ $val }}" @selected(old('type', $campaign->type) === $val)>{{ $lbl }}</option>
                    @endforeach
                </select>
            </div>
            <div>
                <label class="field-label" for="ends_at">Date de fin (optionnel)</label>
                <input id="ends_at" name="ends_at" type="date" value="{{ old('ends_at', optional($campaign->ends_at)->format('Y-m-d')) }}" class="input">
            </div>
            <div>
                <label class="field-label" for="target_amount">Objectif (F CFA)</label>
                <input id="target_amount" name="target_amount" type="number" min="0" step="500" value="{{ old('target_amount', $campaign->target_amount) }}" class="input" placeholder="500000">
                @error('target_amount') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <div>
                <label class="field-label" for="collected_amount">Déjà collecté (F CFA)</label>
                <input id="collected_amount" name="collected_amount" type="number" min="0" step="500" value="{{ old('collected_amount', $campaign->collected_amount ?? 0) }}" class="input">
                <p class="field-hint">Mise à jour manuelle du montant réel collecté.</p>
            </div>
            <div class="sm:col-span-2">
                <label class="field-label" for="description">Description</label>
                <textarea id="description" name="description" class="textarea" rows="4">{{ old('description', $campaign->description) }}</textarea>
            </div>
            <div class="sm:col-span-2">
                <label class="field-label" for="image">Image d'illustration</label>
                @if($campaign->image)<img src="{{ \Illuminate\Support\Facades\Storage::url($campaign->image) }}" class="mb-2 h-24 rounded-xl object-cover" alt="">@endif
                <input id="image" name="image" type="file" accept="image/png,image/jpeg,image/webp" class="block w-full text-sm text-[color:var(--color-ink-soft)] file:mr-3 file:rounded-lg file:border-0 file:bg-[color:var(--color-navy)] file:px-4 file:py-2 file:text-sm file:font-semibold file:text-white">
                @error('image') <p class="field-error">{{ $message }}</p> @enderror
            </div>
            <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm sm:col-span-2">
                <input type="hidden" name="is_active" value="0">
                <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $campaign->is_active ?? true)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                <span><span class="font-medium">Active</span> (visible dans l'application)</span>
            </label>
        </div>
    </div>
    <div class="flex items-center justify-end gap-3">
        <a href="{{ admin_route('campaigns.index') }}" class="btn-ghost">Annuler</a>
        <button type="submit" class="btn-primary"><x-icon name="check" class="h-4 w-4" /> {{ $isEdit ? 'Enregistrer' : 'Créer' }}</button>
    </div>
</form>
