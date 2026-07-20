@extends('movement.layouts.app')
@section('title', 'Tableau de bord')
@section('heading', $movement->name)
@section('subheading', 'Paroisse '.$movement->parish?->name)

@section('content')
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <x-stat-card label="Membres" :value="$movement->members_count" icon="users" tone="navy" />
        <x-stat-card label="Annonces" :value="$movement->posts_count" icon="megaphone" tone="gold" />
        <x-stat-card label="Documents" :value="$movement->documents_count" icon="book" tone="info" />
    </div>

    <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-3">
        <div class="card lg:col-span-2">
            <div class="flex items-center justify-between border-b border-[color:var(--color-border-soft)] px-5 py-4">
                <h3 class="text-base font-bold">Dernières annonces</h3>
                <a href="{{ route('mouvement.posts.index') }}" class="text-sm font-semibold text-[color:var(--color-navy-light)] hover:underline">Tout voir</a>
            </div>
            <div class="divide-y divide-[color:var(--color-border-soft)]">
                @forelse($recentPosts as $post)
                    <div class="flex items-center gap-3 px-5 py-3.5">
                        <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[color:var(--color-gold-soft)] text-[color:var(--color-gold)]"><x-icon name="megaphone" class="h-5 w-5" /></span>
                        <div class="min-w-0 flex-1"><p class="truncate text-sm font-semibold">{{ $post->title }}</p></div>
                        <span class="shrink-0 text-xs text-[color:var(--color-ink-faint)]">{{ optional($post->published_at)->translatedFormat('d M') ?? 'Brouillon' }}</span>
                    </div>
                @empty
                    <p class="px-5 py-8 text-center text-sm text-[color:var(--color-ink-soft)]">Aucune annonce. Publiez la première !</p>
                @endforelse
            </div>
        </div>
        <div class="card card-pad">
            <h3 class="mb-4 text-base font-bold">Actions rapides</h3>
            <div class="space-y-3">
                <a href="{{ route('mouvement.posts.create') }}" class="btn-gold w-full"><x-icon name="plus" class="h-4 w-4" /> Nouvelle annonce</a>
                <a href="{{ route('mouvement.documents.index') }}" class="btn-outline w-full"><x-icon name="book" class="h-4 w-4" /> Ajouter un document</a>
                <a href="{{ route('mouvement.members.index') }}" class="btn-outline w-full"><x-icon name="users" class="h-4 w-4" /> Voir les membres</a>
            </div>
        </div>
    </div>
@endsection
