@extends('admin.layouts.app')

@section('title', 'Horaires de messe')
@section('heading', 'Horaires de messe')
@section('subheading', 'Paroisse '.$parish->name)

@php
    $days = ['Dimanche','Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'];
@endphp

@section('content')
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {{-- Add form --}}
        <div class="lg:col-span-1">
            <form method="POST" action="{{ admin_route('mass-times.store') }}" class="card card-pad space-y-4">
                @csrf
                <h3 class="text-base font-bold">Ajouter un horaire</h3>
                <div>
                    <label class="field-label" for="day_of_week">Jour <span class="text-red-500">*</span></label>
                    <select id="day_of_week" name="day_of_week" class="select" required>
                        @foreach($days as $i => $d)
                            <option value="{{ $i }}" @selected(old('day_of_week') == $i)>{{ $d }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="field-label" for="time">Heure <span class="text-red-500">*</span></label>
                    <input id="time" name="time" type="time" value="{{ old('time') }}" class="input" required>
                </div>
                <div>
                    <label class="field-label" for="label">Intitulé</label>
                    <input id="label" name="label" type="text" value="{{ old('label') }}" class="input" placeholder="Messe dominicale…">
                </div>
                <div>
                    <label class="field-label" for="note">Note</label>
                    <input id="note" name="note" type="text" value="{{ old('note') }}" class="input" placeholder="Chorale, langue…">
                </div>
                <button type="submit" class="btn-primary w-full">
                    <x-icon name="plus" class="h-4 w-4" /> Ajouter
                </button>
            </form>
        </div>

        {{-- List --}}
        <div class="lg:col-span-2">
            <div class="card">
                <div class="border-b border-[color:var(--color-border-soft)] px-5 py-4">
                    <h3 class="text-base font-bold">Horaires actuels ({{ $massTimes->count() }})</h3>
                </div>
                @forelse($massTimes as $mt)
                    <form method="POST" action="{{ admin_route('mass-times.update', $mt) }}"
                          class="flex flex-wrap items-end gap-3 border-b border-[color:var(--color-border-soft)] px-5 py-4">
                        @csrf @method('PATCH')
                        <div class="w-28">
                            <label class="field-label text-xs">Jour</label>
                            <select name="day_of_week" class="select">
                                @foreach($days as $i => $d)
                                    <option value="{{ $i }}" @selected($mt->day_of_week === $i)>{{ $d }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="w-24">
                            <label class="field-label text-xs">Heure</label>
                            <input name="time" type="time" value="{{ $mt->formattedTime() }}" class="input">
                        </div>
                        <div class="min-w-[9rem] flex-1">
                            <label class="field-label text-xs">Intitulé</label>
                            <input name="label" type="text" value="{{ $mt->label }}" class="input" placeholder="—">
                        </div>
                        <div class="min-w-[9rem] flex-1">
                            <label class="field-label text-xs">Note</label>
                            <input name="note" type="text" value="{{ $mt->note }}" class="input" placeholder="—">
                        </div>
                        <button type="submit" class="btn-outline btn-sm" title="Enregistrer">
                            <x-icon name="check" class="h-4 w-4" />
                        </button>
                        <button type="submit" form="del-{{ $mt->id }}" class="btn-sm rounded-xl p-2 text-red-500 hover:bg-red-50" title="Supprimer">
                            <x-icon name="trash" class="h-4 w-4" />
                        </button>
                    </form>
                    <form id="del-{{ $mt->id }}" method="POST" action="{{ admin_route('mass-times.destroy', $mt) }}"
                          onsubmit="return confirm('Supprimer cet horaire ?');" class="hidden">
                        @csrf @method('DELETE')
                    </form>
                @empty
                    <div class="flex flex-col items-center gap-2 py-12 text-center">
                        <x-icon name="calendar" class="h-10 w-10 text-[color:var(--color-ink-faint)]" />
                        <p class="text-sm text-[color:var(--color-ink-soft)]">Aucun horaire pour l'instant. Ajoutez-en un à gauche.</p>
                    </div>
                @endforelse
            </div>
        </div>
    </div>
@endsection
