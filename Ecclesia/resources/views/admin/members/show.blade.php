@extends('admin.layouts.app')

@section('title', $member->fullName())
@section('heading', $member->fullName())
@section('subheading', 'Fiche du fidèle')

@section('actions')
    <a href="{{ admin_route('members.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@section('content')
    <div class="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {{-- Profile card --}}
        <div class="card card-pad lg:col-span-1">
            <div class="flex flex-col items-center text-center">
                <span class="flex h-20 w-20 items-center justify-center rounded-full bg-[color:var(--color-navy)] text-2xl font-bold text-white">
                    {{ strtoupper(mb_substr($member->first_name, 0, 1).mb_substr($member->last_name, 0, 1)) }}
                </span>
                <h3 class="mt-4 text-lg font-bold">{{ $member->fullName() }}</h3>
                <p class="text-sm text-[color:var(--color-ink-soft)]">{{ $member->gender?->label() }}</p>
                <div class="mt-3"><x-status-badge :status="$member->status" /></div>
            </div>

            <div class="mt-6 space-y-3 border-t border-[color:var(--color-border-soft)] pt-5 text-sm">
                <div class="flex items-center justify-between">
                    <span class="text-[color:var(--color-ink-soft)]">Téléphone</span>
                    <span class="font-medium">{{ $member->phone }}</span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-[color:var(--color-ink-soft)]">E-mail</span>
                    <span class="font-medium">{{ $member->email ?? '—' }}</span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-[color:var(--color-ink-soft)]">Paroisse</span>
                    <span class="font-medium">{{ optional($member->parish)->name ?? '—' }}</span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-[color:var(--color-ink-soft)]">Membre depuis</span>
                    <span class="font-medium">{{ optional($member->parish_joined_at)->translatedFormat('d M Y') ?? '—' }}</span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-[color:var(--color-ink-soft)]">Inscrit le</span>
                    <span class="font-medium">{{ $member->created_at->translatedFormat('d M Y') }}</span>
                </div>
            </div>
        </div>

        {{-- Status management --}}
        <div class="card card-pad lg:col-span-2">
            <h3 class="text-base font-bold">Gérer le statut</h3>
            <p class="mt-1 text-sm text-[color:var(--color-ink-soft)]">
                Un fidèle suspendu ne peut plus se connecter à l'application.
            </p>

            <form method="POST" action="{{ admin_route('members.status', $member) }}" class="mt-5 flex flex-col gap-3 sm:flex-row sm:items-end">
                @csrf @method('PATCH')
                <div class="flex-1">
                    <label class="field-label" for="status">Statut du compte</label>
                    <select id="status" name="status" class="select">
                        @foreach(\App\Enums\UserStatus::cases() as $s)
                            <option value="{{ $s->value }}" @selected($member->status === $s)>{{ $s->label() }}</option>
                        @endforeach
                    </select>
                </div>
                <button type="submit" class="btn-primary">
                    <x-icon name="check" class="h-4 w-4" /> Mettre à jour
                </button>
            </form>

            <div class="mt-6 rounded-xl bg-[color:var(--color-surface-muted)] p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-[color:var(--color-ink-soft)]">Paroisse d'appartenance</p>
                @if($member->parish)
                    <div class="mt-2 flex items-center gap-3">
                        <span class="flex h-10 w-10 items-center justify-center rounded-lg bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]">
                            <x-icon name="church" class="h-5 w-5" />
                        </span>
                        <div>
                            <p class="font-semibold">{{ $member->parish->name }}</p>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $member->parish->commune }} · {{ $member->parish->diocese }}</p>
                        </div>
                    </div>
                @else
                    <p class="mt-2 text-sm text-[color:var(--color-ink-soft)]">Ce fidèle n'a pas encore rejoint de paroisse.</p>
                @endif
            </div>
        </div>
    </div>
@endsection
