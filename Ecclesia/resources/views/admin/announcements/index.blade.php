@extends('admin.layouts.app')

@section('title', 'Annonces')
@section('heading', 'Annonces')
@section('subheading', 'Fil paroissial diffusé dans l\'application')

@section('actions')
    <a href="{{ admin_route('announcements.create') }}" class="btn-primary">
        <x-icon name="plus" class="h-4 w-4" /> Nouvelle annonce
    </a>
@endsection

@section('content')
    {{-- Filters --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <div class="relative flex-1">
            <span class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-[color:var(--color-ink-faint)]">
                <x-icon name="search" class="h-5 w-5" />
            </span>
            <input type="text" name="q" value="{{ $search }}" placeholder="Rechercher un titre…" class="input pl-10">
        </div>
        <select name="category" class="select sm:w-52" onchange="this.form.submit()">
            <option value="">Toutes les catégories</option>
            @foreach($categories as $c)
                <option value="{{ $c->value }}" @selected($category === $c->value)>{{ $c->label() }}</option>
            @endforeach
        </select>
        <button type="submit" class="btn-outline">Filtrer</button>
    </form>

    {{-- Cards grid --}}
    @if($announcements->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="megaphone" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucune annonce pour l'instant.</p>
            <a href="{{ admin_route('announcements.create') }}" class="btn-primary mt-2">
                <x-icon name="plus" class="h-4 w-4" /> Créer la première annonce
            </a>
        </div>
    @else
        <div class="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-3">
            @foreach($announcements as $a)
                @php
                    $isLive = $a->published_at !== null && $a->published_at->lessThanOrEqualTo(now());
                    $isScheduled = $a->published_at !== null && $a->published_at->greaterThan(now());
                @endphp
                <div class="card flex flex-col overflow-hidden">
                    @if($a->image_url)
                        <div class="h-36 w-full overflow-hidden bg-[color:var(--color-surface-muted)]">
                            <img src="{{ $a->image_url }}" alt="" class="h-full w-full object-cover" loading="lazy"
                                 onerror="this.parentElement.style.display='none'">
                        </div>
                    @endif
                    <div class="flex flex-1 flex-col p-5">
                        <div class="mb-2 flex flex-wrap items-center gap-1.5">
                            <span class="badge-gold">{{ $a->category->label() }}</span>
                            @if($a->is_pinned)<span class="badge-navy"><x-icon name="pin" class="h-3 w-3" /> Épinglée</span>@endif
                            @if($a->is_important)<span class="badge-danger">Importante</span>@endif
                        </div>
                        <h3 class="text-base font-bold leading-snug text-[color:var(--color-navy-dark)]">{{ $a->title }}</h3>
                        <p class="mt-1.5 line-clamp-2 flex-1 text-sm text-[color:var(--color-ink-soft)]">{{ \Illuminate\Support\Str::limit(strip_tags($a->body), 120) }}</p>

                        <div class="mt-3 flex items-center gap-2 text-xs text-[color:var(--color-ink-soft)]">
                            <span class="font-medium text-[color:var(--color-ink)]">{{ $a->author_name }}</span>
                            @if($a->parish)<span>· {{ $a->parish->name }}</span>@endif
                        </div>

                        <div class="mt-4 flex items-center justify-between border-t border-[color:var(--color-border-soft)] pt-3">
                            <div class="flex items-center gap-2 text-xs">
                                @if($isLive)
                                    <span class="badge-success">● En ligne</span>
                                    <span class="text-[color:var(--color-ink-faint)]">{{ $a->published_at->translatedFormat('d M Y') }}</span>
                                @elseif($isScheduled)
                                    <span class="badge-gold"><x-icon name="calendar" class="h-3 w-3" /> Programmée</span>
                                    <span class="text-[color:var(--color-ink-faint)]">{{ $a->published_at->translatedFormat('d M H:i') }}</span>
                                @else
                                    <span class="badge-muted">Brouillon</span>
                                @endif
                            </div>
                            <div class="flex items-center gap-1">
                                <a href="{{ admin_route('announcements.edit', $a) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier">
                                    <x-icon name="edit" class="h-4 w-4" />
                                </a>
                                <form method="POST" action="{{ admin_route('announcements.destroy', $a) }}"
                                      onsubmit="return confirm('Supprimer « {{ $a->title }} » ?');">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50" title="Supprimer">
                                        <x-icon name="trash" class="h-4 w-4" />
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="mt-6">{{ $announcements->links() }}</div>
    @endif
@endsection
