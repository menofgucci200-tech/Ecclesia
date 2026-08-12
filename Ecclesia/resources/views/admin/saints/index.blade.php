@extends('admin.layouts.app')

@section('title', 'Saints du jour')
@section('heading', 'Saints du jour')
@section('subheading', 'Auto-rempli depuis AELF + Wikipédia — éditable et masquable')

@section('actions')
    <form method="POST" action="{{ admin_route('saints.sync-upcoming') }}">
        @csrf
        <button type="submit" class="btn-primary">
            <x-icon name="sparkles" class="h-4 w-4" /> Synchroniser 14 jours
        </button>
    </form>
@endsection

@section('content')
    @if($saints->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="sparkles" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucun saint pour l'instant.</p>
        </div>
    @else
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-3">
            @foreach($saints as $s)
                <div class="card card-pad flex flex-col {{ $s->is_hidden ? 'opacity-60' : '' }}">
                    <div class="flex items-start gap-3">
                        <div class="h-16 w-16 shrink-0 overflow-hidden rounded-xl bg-[color:var(--color-surface-muted)]">
                            @if($s->image_url)
                                <img src="{{ $s->image_url }}" alt="" class="h-full w-full object-cover" loading="lazy" onerror="this.style.display='none'">
                            @else
                                <div class="flex h-full w-full items-center justify-center"><x-icon name="sparkles" class="h-6 w-6 text-[color:var(--color-ink-faint)]" /></div>
                            @endif
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="text-xs font-bold uppercase tracking-wide text-[color:var(--color-gold)]">{{ $s->date->translatedFormat('D d M Y') }}</p>
                            <h3 class="truncate text-base font-bold text-[color:var(--color-navy-dark)]">{{ $s->name ?? 'Férie' }}</h3>
                            @if($s->feast)<p class="line-clamp-2 text-xs text-[color:var(--color-ink-soft)]">{{ $s->feast }}</p>@endif
                        </div>
                        @if($s->is_hidden)<span class="badge-muted shrink-0">Masqué</span>@endif
                    </div>

                    @if($s->summary)
                        <p class="mt-3 line-clamp-3 flex-1 text-sm text-[color:var(--color-ink-soft)]">{{ $s->summary }}</p>
                    @else
                        <p class="mt-3 flex-1 text-sm italic text-[color:var(--color-ink-faint)]">Pas de biographie.</p>
                    @endif

                    <div class="mt-4 flex items-center justify-end gap-1 border-t border-[color:var(--color-border-soft)] pt-3">
                        <form method="POST" action="{{ admin_route('saints.resync', $s) }}">
                            @csrf
                            <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Resynchroniser">
                                <x-icon name="sparkles" class="h-4 w-4" />
                            </button>
                        </form>
                        <form method="POST" action="{{ admin_route('saints.toggle', $s) }}">
                            @csrf @method('PATCH')
                            <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="{{ $s->is_hidden ? 'Afficher' : 'Masquer' }}">
                                <x-icon name="eye" class="h-4 w-4" />
                            </button>
                        </form>
                        <a href="{{ admin_route('saints.edit', $s) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier">
                            <x-icon name="edit" class="h-4 w-4" />
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
        <div class="mt-6">{{ $saints->links() }}</div>
    @endif
@endsection
