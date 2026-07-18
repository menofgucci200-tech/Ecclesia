@extends('admin.layouts.app')

@section('title', 'Modifier la liturgie')
@section('heading', 'Modifier la liturgie')
@section('subheading', $liturgy->date->translatedFormat('l d F Y'))

@section('actions')
    <a href="{{ admin_route('liturgies.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@php
    $typeLabels = [
        'lecture_1' => 'Première lecture', 'psaume' => 'Psaume', 'lecture_2' => 'Deuxième lecture',
        'evangile' => 'Évangile', 'cantique' => 'Cantique', 'sequence' => 'Séquence',
    ];
@endphp

@section('content')
    <form method="POST" action="{{ admin_route('liturgies.update', $liturgy) }}" class="mx-auto max-w-3xl space-y-6">
        @csrf @method('PUT')

        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Informations du jour</h3>
            <div class="grid grid-cols-1 gap-5 sm:grid-cols-2">
                <div class="sm:col-span-2">
                    <label class="field-label" for="liturgical_day">Jour liturgique <span class="text-red-500">*</span></label>
                    <input id="liturgical_day" name="liturgical_day" type="text" value="{{ old('liturgical_day', $liturgy->liturgical_day) }}" class="input" required>
                    @error('liturgical_day') <p class="field-error">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="field-label" for="season">Temps liturgique</label>
                    <input id="season" name="season" type="text" value="{{ old('season', $liturgy->season) }}" class="input">
                </div>
                <div>
                    <label class="field-label" for="color">Couleur</label>
                    <input id="color" name="color" type="text" value="{{ old('color', $liturgy->color) }}" class="input" placeholder="vert, blanc, rouge…">
                </div>
                <div class="sm:col-span-2">
                    <label class="field-label" for="week">Semaine</label>
                    <input id="week" name="week" type="text" value="{{ old('week', $liturgy->week) }}" class="input">
                </div>
            </div>
        </div>

        @foreach(($liturgy->readings ?? []) as $i => $reading)
            <div class="card card-pad">
                <div class="mb-4 flex items-center gap-2">
                    <h3 class="text-base font-bold">{{ $typeLabels[$reading['type'] ?? ''] ?? ucfirst($reading['type'] ?? 'Lecture') }}</h3>
                    <span class="badge-muted">{{ $reading['ref'] ?? '' }}</span>
                </div>
                <input type="hidden" name="readings[{{ $i }}][type]" value="{{ $reading['type'] ?? '' }}">
                <input type="hidden" name="readings[{{ $i }}][intro]" value="{{ $reading['intro'] ?? '' }}">
                <input type="hidden" name="readings[{{ $i }}][refrain]" value="{{ $reading['refrain'] ?? '' }}">
                <input type="hidden" name="readings[{{ $i }}][verse]" value="{{ $reading['verse'] ?? '' }}">
                <div class="space-y-4">
                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div>
                            <label class="field-label text-xs">Référence</label>
                            <input name="readings[{{ $i }}][ref]" type="text" value="{{ $reading['ref'] ?? '' }}" class="input">
                        </div>
                        <div class="sm:col-span-2">
                            <label class="field-label text-xs">Titre</label>
                            <input name="readings[{{ $i }}][title]" type="text" value="{{ $reading['title'] ?? '' }}" class="input">
                        </div>
                    </div>
                    <div>
                        <label class="field-label text-xs">Contenu (HTML autorisé)</label>
                        <textarea name="readings[{{ $i }}][content]" class="textarea min-h-[160px] font-mono text-xs">{{ $reading['content'] ?? '' }}</textarea>
                    </div>
                </div>
            </div>
        @endforeach

        <div class="flex items-center justify-between gap-3">
            <p class="text-xs text-[color:var(--color-ink-soft)]">Après enregistrement, cette liturgie sera « Modifiée » et protégée de la synchro automatique.</p>
            <div class="flex gap-3">
                <a href="{{ admin_route('liturgies.index') }}" class="btn-ghost">Annuler</a>
                <button type="submit" class="btn-primary"><x-icon name="check" class="h-4 w-4" /> Enregistrer</button>
            </div>
        </div>
    </form>
@endsection
