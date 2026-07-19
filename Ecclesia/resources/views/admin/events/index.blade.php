@extends('admin.layouts.app')

@section('title', 'Événements')
@section('heading', 'Événements de la paroisse')
@section('subheading', $parish->name)

@section('actions')
    <a href="{{ admin_route('events.create') }}" class="btn-primary">
        <x-icon name="plus" class="h-4 w-4" /> Nouvel événement
    </a>
@endsection

@section('content')
    @if($events->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="calendar" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm text-[color:var(--color-ink-soft)]">Aucun événement pour l'instant.</p>
            <a href="{{ admin_route('events.create') }}" class="btn-primary mt-2"><x-icon name="plus" class="h-4 w-4" /> Créer le premier</a>
        </div>
    @else
        <div class="card">
            <div class="table-wrap">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Événement</th>
                            <th>Date</th>
                            <th>Lieu</th>
                            <th>Statut</th>
                            <th class="text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($events as $event)
                            <tr>
                                <td>
                                    <div class="flex items-center gap-3">
                                        <span class="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-[color:var(--color-gold-soft)] text-[color:var(--color-gold)]">
                                            @if($event->image)
                                                <img src="{{ \Illuminate\Support\Facades\Storage::url($event->image) }}" alt="" class="h-full w-full object-cover">
                                            @else
                                                <x-icon name="calendar" class="h-5 w-5" />
                                            @endif
                                        </span>
                                        <p class="font-semibold text-[color:var(--color-ink)]">{{ $event->title }}</p>
                                    </div>
                                </td>
                                <td class="whitespace-nowrap text-[color:var(--color-ink-soft)]">{{ $event->starts_at->translatedFormat('d M Y · H\hi') }}</td>
                                <td class="text-[color:var(--color-ink-soft)]">{{ $event->location ?? '—' }}</td>
                                <td>
                                    @if($event->is_published)
                                        <span class="badge-success">Publié</span>
                                    @else
                                        <span class="badge-muted">Brouillon</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="flex items-center justify-end gap-1">
                                        <a href="{{ admin_route('events.edit', $event) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]"><x-icon name="edit" class="h-4 w-4" /></a>
                                        <form method="POST" action="{{ admin_route('events.destroy', $event) }}" onsubmit="return confirm('Supprimer « {{ $event->title }} » ?');">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50"><x-icon name="trash" class="h-4 w-4" /></button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
        <div class="mt-4">{{ $events->links() }}</div>
    @endif
@endsection
