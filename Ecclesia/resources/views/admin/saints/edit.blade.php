@extends('admin.layouts.app')

@section('title', 'Modifier le saint du jour')
@section('heading', $saint->name ?? 'Férie')
@section('subheading', $saint->date->translatedFormat('l d F Y'))

@section('actions')
    <a href="{{ admin_route('saints.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@section('content')
    <form method="POST" action="{{ admin_route('saints.update', $saint) }}" class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        @csrf @method('PUT')

        <div class="space-y-6 lg:col-span-2">
            <div class="card card-pad">
                <h3 class="mb-4 text-base font-bold">Contenu</h3>
                <div class="space-y-5">
                    <div>
                        <label class="field-label" for="name">Nom du saint</label>
                        <input id="name" name="name" type="text" value="{{ old('name', $saint->name) }}" class="input" placeholder="Ex. Laurent de Brindisi">
                        @error('name') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="field-label" for="feast">Fête (libellé liturgique)</label>
                        <input id="feast" name="feast" type="text" value="{{ old('feast', $saint->feast) }}" class="input">
                        @error('feast') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="field-label" for="summary">Biographie</label>
                        <textarea id="summary" name="summary" class="textarea" rows="10">{{ old('summary', $saint->summary) }}</textarea>
                        @error('summary') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                </div>
            </div>
        </div>

        <div class="space-y-6">
            <div class="card card-pad">
                <h3 class="mb-4 text-base font-bold">Image & liens</h3>
                <div class="space-y-5">
                    @if($saint->image_url)
                        <img src="{{ $saint->image_url }}" alt="" class="h-40 w-full rounded-xl object-cover" onerror="this.style.display='none'">
                    @endif
                    <div>
                        <label class="field-label" for="image_url">URL de l'image</label>
                        <input id="image_url" name="image_url" type="url" value="{{ old('image_url', $saint->image_url) }}" class="input" placeholder="https://…">
                        @error('image_url') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label class="field-label" for="wikipedia_url">Lien Wikipédia</label>
                        <input id="wikipedia_url" name="wikipedia_url" type="url" value="{{ old('wikipedia_url', $saint->wikipedia_url) }}" class="input" placeholder="https://fr.wikipedia.org/…">
                        @error('wikipedia_url') <p class="field-error">{{ $message }}</p> @enderror
                    </div>
                    <label class="flex items-center gap-3 rounded-xl border border-[color:var(--color-border-soft)] px-3.5 py-3 text-sm">
                        <input type="hidden" name="is_hidden" value="0">
                        <input type="checkbox" name="is_hidden" value="1" @checked(old('is_hidden', $saint->is_hidden)) class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                        <span><span class="font-medium">Masquer</span> dans l'application</span>
                    </label>
                </div>
            </div>

            <div class="flex items-center justify-end gap-3">
                <a href="{{ admin_route('saints.index') }}" class="btn-ghost">Annuler</a>
                <button type="submit" class="btn-primary">
                    <x-icon name="check" class="h-4 w-4" /> Enregistrer
                </button>
            </div>
        </div>
    </form>
@endsection
