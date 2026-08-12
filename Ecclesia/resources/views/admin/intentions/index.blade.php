@extends('admin.layouts.app')

@section('title', 'Intentions de prière')
@section('heading', 'Intentions de prière')
@section('subheading', 'Modérez le mur d\'intentions de vos fidèles')

@section('content')
    @if($intentions->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="megaphone" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucune intention pour l'instant.</p>
        </div>
    @else
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            @foreach($intentions as $i)
                <div class="card card-pad flex flex-col {{ $i->is_approved ? '' : 'opacity-60' }}">
                    <div class="flex items-start justify-between gap-2">
                        <div class="flex items-center gap-2">
                            <span class="badge-navy">{{ $i->displayName() }}</span>
                            @if($i->parish)<span class="text-xs text-[color:var(--color-ink-soft)]">· {{ $i->parish->name }}</span>@endif
                        </div>
                        @unless($i->is_approved)<span class="badge-muted shrink-0">Masquée</span>@endunless
                    </div>
                    <p class="mt-3 flex-1 text-sm text-[color:var(--color-ink)]">{{ $i->intention }}</p>
                    <div class="mt-4 flex items-center justify-between border-t border-[color:var(--color-border-soft)] pt-3">
                        <span class="text-xs text-[color:var(--color-ink-soft)]">
                            🙏 {{ $i->prayers_count }} · {{ $i->created_at->translatedFormat('d M Y') }}
                        </span>
                        <div class="flex items-center gap-1">
                            <form method="POST" action="{{ admin_route('intentions.toggle', $i) }}">
                                @csrf @method('PATCH')
                                <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="{{ $i->is_approved ? 'Masquer' : 'Afficher' }}">
                                    <x-icon name="eye" class="h-4 w-4" />
                                </button>
                            </form>
                            <form method="POST" action="{{ admin_route('intentions.destroy', $i) }}" onsubmit="return confirm('Supprimer cette intention ?');">
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
        <div class="mt-6">{{ $intentions->links() }}</div>
    @endif
@endsection
