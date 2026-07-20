@extends('movement.layouts.app')
@section('title', 'Membres')
@section('heading', 'Membres du mouvement')
@section('subheading', $movement->members()->count().' membre(s)')
@section('content')
    <div class="card">
        <div class="table-wrap">
            <table class="data-table">
                <thead><tr><th>Membre</th><th>Contact</th><th>Membre depuis</th></tr></thead>
                <tbody>
                    @forelse($members as $m)
                        <tr>
                            <td>
                                <div class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[color:var(--color-navy)]/10 text-xs font-bold text-[color:var(--color-navy)]">{{ strtoupper(mb_substr($m->first_name,0,1).mb_substr($m->last_name,0,1)) }}</span>
                                    <p class="font-semibold text-[color:var(--color-ink)]">{{ $m->fullName() }}</p>
                                </div>
                            </td>
                            <td class="text-[color:var(--color-ink-soft)]">{{ $m->phone ?? $m->email ?? '—' }}</td>
                            <td class="text-[color:var(--color-ink-soft)]">{{ optional($m->pivot->joined_at ? \Illuminate\Support\Carbon::parse($m->pivot->joined_at) : $m->pivot->created_at)->translatedFormat('d M Y') }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="3"><div class="flex flex-col items-center gap-2 py-12 text-center"><x-icon name="users" class="h-10 w-10 text-[color:var(--color-ink-faint)]" /><p class="text-sm text-[color:var(--color-ink-soft)]">Aucun membre pour l'instant.</p></div></td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
    <div class="mt-4">{{ $members->links() }}</div>
@endsection
