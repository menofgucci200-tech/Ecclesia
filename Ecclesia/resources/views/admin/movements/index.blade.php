@extends('admin.layouts.app')

@section('title', 'Mouvements')
@section('heading', 'Mouvements')
@section('subheading', 'Groupes et mouvements de '.$parish->name)

@section('actions')
    <a href="{{ admin_route('movements.create') }}" class="btn-primary">
        <x-icon name="plus" class="h-4 w-4" /> Nouveau mouvement
    </a>
@endsection

@section('content')
    @if($movements->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="users" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm text-[color:var(--color-ink-soft)]">Aucun mouvement pour l'instant.</p>
            <a href="{{ admin_route('movements.create') }}" class="btn-primary mt-2"><x-icon name="plus" class="h-4 w-4" /> Créer le premier</a>
        </div>
    @else
        <div class="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-3">
            @foreach($movements as $movement)
                <div class="card card-pad">
                    <div class="flex items-center gap-3">
                        <span class="flex h-12 w-12 shrink-0 items-center justify-center overflow-hidden rounded-xl bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]">
                            @if($movement->logo)
                                <img src="{{ \Illuminate\Support\Facades\Storage::url($movement->logo) }}" alt="" class="h-full w-full object-cover">
                            @else
                                <x-icon name="users" class="h-6 w-6" />
                            @endif
                        </span>
                        <div class="min-w-0 flex-1">
                            <p class="truncate font-bold text-[color:var(--color-navy-dark)]">{{ $movement->name }}</p>
                            <p class="truncate text-xs text-[color:var(--color-ink-soft)]">{{ $movement->category ?? 'Mouvement' }}</p>
                        </div>
                        @if($movement->is_active)
                            <span class="badge-success">Actif</span>
                        @else
                            <span class="badge-muted">Inactif</span>
                        @endif
                    </div>
                    <div class="mt-3 flex items-center gap-4 text-xs text-[color:var(--color-ink-soft)]">
                        <span class="inline-flex items-center gap-1"><x-icon name="users" class="h-4 w-4" /> {{ $movement->members_count }} membre(s)</span>
                        @if($movement->admin?->username)<span class="inline-flex items-center gap-1">🔑 {{ $movement->admin->username }}</span>@endif
                    </div>
                    <div class="mt-4 flex items-center justify-end gap-1 border-t border-[color:var(--color-border-soft)] pt-3">
                        <a href="{{ admin_route('movements.edit', $movement) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier"><x-icon name="edit" class="h-4 w-4" /></a>
                        <form method="POST" action="{{ admin_route('movements.destroy', $movement) }}" onsubmit="return confirm('Supprimer « {{ $movement->name }} » et son compte responsable ?');">
                            @csrf @method('DELETE')
                            <button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50" title="Supprimer"><x-icon name="trash" class="h-4 w-4" /></button>
                        </form>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
