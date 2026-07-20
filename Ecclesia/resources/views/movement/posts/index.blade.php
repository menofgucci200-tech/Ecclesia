@extends('movement.layouts.app')
@section('title', 'Annonces')
@section('heading', 'Annonces du mouvement')
@section('actions')
    <a href="{{ route('mouvement.posts.create') }}" class="btn-primary"><x-icon name="plus" class="h-4 w-4" /> Nouvelle annonce</a>
@endsection
@section('content')
    @if($posts->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="megaphone" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm text-[color:var(--color-ink-soft)]">Aucune annonce pour l'instant.</p>
            <a href="{{ route('mouvement.posts.create') }}" class="btn-primary mt-2"><x-icon name="plus" class="h-4 w-4" /> Publier la première</a>
        </div>
    @else
        <div class="space-y-4">
            @foreach($posts as $post)
                <div class="card card-pad flex items-start gap-4">
                    @if($post->image)<img src="{{ \Illuminate\Support\Facades\Storage::url($post->image) }}" class="h-16 w-16 shrink-0 rounded-xl object-cover" alt="">@endif
                    <div class="min-w-0 flex-1">
                        <p class="font-bold text-[color:var(--color-navy-dark)]">{{ $post->title }}</p>
                        <p class="mt-1 line-clamp-2 text-sm text-[color:var(--color-ink-soft)]">{{ \Illuminate\Support\Str::limit(strip_tags($post->body), 140) }}</p>
                        <p class="mt-2 text-xs text-[color:var(--color-ink-faint)]">{{ optional($post->published_at)->translatedFormat('d M Y · H\hi') ?? 'Brouillon' }}</p>
                    </div>
                    <div class="flex shrink-0 items-center gap-1">
                        <a href="{{ route('mouvement.posts.edit', $post) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]"><x-icon name="edit" class="h-4 w-4" /></a>
                        <form method="POST" action="{{ route('mouvement.posts.destroy', $post) }}" onsubmit="return confirm('Supprimer cette annonce ?');">@csrf @method('DELETE')<button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50"><x-icon name="trash" class="h-4 w-4" /></button></form>
                    </div>
                </div>
            @endforeach
        </div>
        <div class="mt-4">{{ $posts->links() }}</div>
    @endif
@endsection
