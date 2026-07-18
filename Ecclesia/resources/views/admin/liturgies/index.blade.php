@extends('admin.layouts.app')

@section('title', 'Liturgie')
@section('heading', 'Liturgie du jour')
@section('subheading', 'Alimentée automatiquement depuis AELF (zone Afrique)')

@section('actions')
    <form method="POST" action="{{ admin_route('liturgies.sync-upcoming') }}">
        @csrf
        <button type="submit" class="btn-primary">
            <x-icon name="sparkles" class="h-4 w-4" /> Synchroniser la semaine
        </button>
    </form>
@endsection

@php
    $colorDot = [
        'vert' => 'bg-emerald-500', 'blanc' => 'bg-slate-300', 'rouge' => 'bg-red-500',
        'violet' => 'bg-purple-500', 'rose' => 'bg-pink-400', 'noir' => 'bg-slate-800',
    ];
@endphp

@section('content')
    <div class="card">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Jour liturgique</th>
                        <th>Couleur</th>
                        <th>Source</th>
                        <th>App</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($liturgies as $l)
                        @php $isToday = $l->date->isToday(); @endphp
                        <tr class="{{ $isToday ? 'bg-[color:var(--color-gold-soft)]/40' : '' }}">
                            <td class="whitespace-nowrap">
                                <p class="font-semibold text-[color:var(--color-ink)]">{{ $l->date->translatedFormat('D d M') }}</p>
                                @if($isToday)<span class="badge-gold">Aujourd'hui</span>@endif
                            </td>
                            <td>
                                <p class="font-medium text-[color:var(--color-ink)]">{{ \Illuminate\Support\Str::limit($l->liturgical_day, 48) }}</p>
                                <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $l->gospel()['ref'] ?? '' }}</p>
                            </td>
                            <td>
                                <span class="inline-flex items-center gap-1.5 text-sm">
                                    <span class="h-3 w-3 rounded-full {{ $colorDot[$l->color] ?? 'bg-slate-300' }}"></span>
                                    {{ ucfirst($l->color ?? '—') }}
                                </span>
                            </td>
                            <td>
                                @if($l->source === 'manual')
                                    <span class="badge-navy">Modifiée</span>
                                @else
                                    <span class="badge-muted">AELF</span>
                                @endif
                            </td>
                            <td>
                                @if($l->is_hidden)
                                    <span class="badge-danger">Masquée</span>
                                @else
                                    <span class="badge-success">Visible</span>
                                @endif
                            </td>
                            <td>
                                <div class="flex items-center justify-end gap-1">
                                    <a href="{{ admin_route('liturgies.edit', $l) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier">
                                        <x-icon name="edit" class="h-4 w-4" />
                                    </a>
                                    <form method="POST" action="{{ admin_route('liturgies.toggle', $l) }}">
                                        @csrf @method('PATCH')
                                        <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="{{ $l->is_hidden ? 'Afficher' : 'Masquer' }}">
                                            <x-icon name="eye" class="h-4 w-4" />
                                        </button>
                                    </form>
                                    <form method="POST" action="{{ admin_route('liturgies.resync', $l) }}"
                                          onsubmit="return confirm('Re-synchroniser depuis AELF ? Les modifications manuelles seront écrasées.');">
                                        @csrf
                                        <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Re-synchroniser AELF">
                                            <x-icon name="sparkles" class="h-4 w-4" />
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    <p class="mt-3 text-xs text-[color:var(--color-ink-soft)]">
        La liturgie se met à jour automatiquement chaque nuit. « Modifiée » = édition manuelle (protégée de la synchro). Vous pouvez la masquer ou la réinitialiser depuis AELF.
    </p>
@endsection
