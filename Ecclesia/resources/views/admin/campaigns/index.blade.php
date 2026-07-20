@extends('admin.layouts.app')
@section('title', 'Dons & collectes')
@section('heading', 'Dons & collectes')
@section('subheading', $parish->name)
@section('actions')
    <a href="{{ admin_route('campaigns.create') }}" class="btn-primary"><x-icon name="plus" class="h-4 w-4" /> Nouvelle collecte</a>
@endsection
@section('content')
    @if($campaigns->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="gift" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm text-[color:var(--color-ink-soft)]">Aucune collecte pour l'instant.</p>
            <a href="{{ admin_route('campaigns.create') }}" class="btn-primary mt-2"><x-icon name="plus" class="h-4 w-4" /> Créer la première</a>
        </div>
    @else
        <div class="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-3">
            @foreach($campaigns as $c)
                <div class="card flex flex-col overflow-hidden">
                    @if($c->image)<div class="h-32 w-full overflow-hidden bg-[color:var(--color-surface-muted)]"><img src="{{ \Illuminate\Support\Facades\Storage::url($c->image) }}" class="h-full w-full object-cover" alt=""></div>@endif
                    <div class="flex flex-1 flex-col p-5">
                        <div class="mb-2 flex items-center gap-2">
                            <span class="badge-gold">{{ $c->typeLabel() }}</span>
                            @if($c->is_active)<span class="badge-success">Active</span>@else<span class="badge-muted">Inactive</span>@endif
                        </div>
                        <h3 class="text-base font-bold text-[color:var(--color-navy-dark)]">{{ $c->title }}</h3>
                        @if($c->target_amount)
                            <div class="mt-3">
                                <div class="mb-1 flex items-center justify-between text-xs">
                                    <span class="font-semibold text-[color:var(--color-navy)]">{{ number_format($c->collected_amount,0,',',' ') }} F</span>
                                    <span class="text-[color:var(--color-ink-soft)]">/ {{ number_format($c->target_amount,0,',',' ') }} F</span>
                                </div>
                                <div class="h-2 overflow-hidden rounded-full bg-[color:var(--color-surface-muted)]"><div class="h-full rounded-full bg-[color:var(--color-gold)]" style="width: {{ $c->progress() }}%"></div></div>
                            </div>
                        @endif
                        <div class="mt-4 flex items-center justify-end gap-1 border-t border-[color:var(--color-border-soft)] pt-3">
                            <a href="{{ admin_route('campaigns.edit', $c) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]"><x-icon name="edit" class="h-4 w-4" /></a>
                            <form method="POST" action="{{ admin_route('campaigns.destroy', $c) }}" onsubmit="return confirm('Supprimer « {{ $c->title }} » ?');">@csrf @method('DELETE')<button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50"><x-icon name="trash" class="h-4 w-4" /></button></form>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
        <div class="mt-6">{{ $campaigns->links() }}</div>
    @endif
@endsection
