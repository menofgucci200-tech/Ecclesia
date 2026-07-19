@extends('admin.layouts.app')

@section('title', 'Calendrier liturgique')
@section('heading', 'Calendrier liturgique')
@section('subheading', 'Fêtes majeures — alimentées automatiquement depuis LitCal')

@section('actions')
    <form method="POST" action="{{ admin_route('calendar.resync') }}">
        @csrf
        <button type="submit" class="btn-primary"><x-icon name="sparkles" class="h-4 w-4" /> Re-synchroniser</button>
    </form>
@endsection

@php
    $colorDot = [
        'vert' => 'bg-emerald-500', 'blanc' => 'bg-slate-300', 'rouge' => 'bg-red-500',
        'violet' => 'bg-purple-500', 'rose' => 'bg-pink-400',
    ];
@endphp

@section('content')
    <div class="card">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Fête</th>
                        <th>Rang</th>
                        <th>App</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($events as $e)
                        <tr class="{{ $e->date->isToday() ? 'bg-[color:var(--color-gold-soft)]/40' : '' }}">
                            <td class="whitespace-nowrap font-semibold text-[color:var(--color-ink)]">{{ $e->date->translatedFormat('D d M Y') }}</td>
                            <td>
                                <div class="flex items-center gap-2">
                                    <span class="h-3 w-3 shrink-0 rounded-full {{ $colorDot[$e->color] ?? 'bg-slate-300' }}"></span>
                                    <span class="font-medium text-[color:var(--color-ink)]">{{ $e->name }}</span>
                                </div>
                            </td>
                            <td><span class="badge-gold">{{ $e->grade_label }}</span></td>
                            <td>
                                @if($e->is_hidden)
                                    <span class="badge-danger">Masquée</span>
                                @else
                                    <span class="badge-success">Visible</span>
                                @endif
                            </td>
                            <td class="text-right">
                                <form method="POST" action="{{ admin_route('calendar.toggle', $e) }}" class="inline">
                                    @csrf @method('PATCH')
                                    <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="{{ $e->is_hidden ? 'Afficher' : 'Masquer' }}">
                                        <x-icon name="eye" class="h-4 w-4" />
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    <p class="mt-3 text-xs text-[color:var(--color-ink-soft)]">
        Ces fêtes alimentent la section « Événements à venir » et l'agenda de l'application. Chaque paroisse ajoute en plus ses propres événements.
    </p>
@endsection
