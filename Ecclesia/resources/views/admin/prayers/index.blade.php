@extends('admin.layouts.app')

@section('title', 'Prières & Chapelets')
@section('heading', 'Prières & Chapelets')
@section('subheading', ($isParish ?? false) ? 'Les contenus propres à votre paroisse (en plus de la bibliothèque commune)' : 'Bibliothèque commune diffusée à toutes les paroisses')

@section('actions')
    <a href="{{ admin_route('prayers.create') }}" class="btn-primary">
        <x-icon name="plus" class="h-4 w-4" /> Nouveau contenu
    </a>
@endsection

@section('content')
    {{-- Filter --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <select name="category" class="select sm:w-60" onchange="this.form.submit()">
            <option value="">Toutes les catégories</option>
            @foreach($categories as $c)
                <option value="{{ $c->value }}" @selected($category === $c->value)>{{ $c->pluralLabel() }}</option>
            @endforeach
        </select>
        <button type="submit" class="btn-outline">Filtrer</button>
    </form>

    @forelse($grouped as $categoryValue => $items)
        @php $cat = \App\Enums\PrayerCategory::from($categoryValue); @endphp
        <div class="mb-7">
            <h3 class="mb-3 text-xs font-bold uppercase tracking-widest text-[color:var(--color-ink-soft)]">
                {{ $cat->pluralLabel() }} <span class="text-[color:var(--color-ink-faint)]">· {{ count($items) }}</span>
            </h3>
            <div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-3">
                @foreach($items as $p)
                    <div class="card card-pad flex flex-col">
                        <div class="flex items-start justify-between gap-3">
                            <div class="flex min-w-0 items-start gap-3">
                                @if($p->image)
                                    <img src="{{ \Illuminate\Support\Facades\Storage::url($p->image) }}" alt="" class="h-12 w-12 shrink-0 rounded-lg object-cover">
                                @endif
                                <div class="min-w-0">
                                    <h4 class="truncate text-base font-bold text-[color:var(--color-navy-dark)]">{{ $p->title }}</h4>
                                    @if($p->subtitle)
                                        <p class="truncate text-sm text-[color:var(--color-ink-soft)]">{{ $p->subtitle }}</p>
                                    @endif
                                </div>
                            </div>
                            @unless($p->is_published)<span class="badge-muted shrink-0">Brouillon</span>@endunless
                        </div>
                        <p class="mt-2 line-clamp-3 flex-1 whitespace-pre-line text-sm text-[color:var(--color-ink-soft)]">{{ \Illuminate\Support\Str::limit($p->body, 160) }}</p>
                        <div class="mt-4 flex items-center justify-between border-t border-[color:var(--color-border-soft)] pt-3">
                            <span class="truncate text-xs text-[color:var(--color-ink-faint)]">{{ $p->reference ?? '' }}</span>
                            <div class="flex shrink-0 items-center gap-1">
                                <a href="{{ admin_route('prayers.edit', $p) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier">
                                    <x-icon name="edit" class="h-4 w-4" />
                                </a>
                                <form method="POST" action="{{ admin_route('prayers.destroy', $p) }}"
                                      onsubmit="return confirm('Supprimer « {{ $p->title }} » ?');">
                                    @csrf @method('DELETE')
                                    <button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50" title="Supprimer">
                                        <x-icon name="trash" class="h-4 w-4" />
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @empty
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="heart" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucun contenu pour l'instant.</p>
            <a href="{{ admin_route('prayers.create') }}" class="btn-primary mt-2">
                <x-icon name="plus" class="h-4 w-4" /> Créer le premier contenu
            </a>
        </div>
    @endforelse
@endsection
