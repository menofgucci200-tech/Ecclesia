@extends('admin.layouts.app')

@section('title', 'Paroisses')
@section('heading', 'Paroisses')
@section('subheading', $parishes->total().' paroisse(s) enregistrée(s)')

@section('actions')
    <a href="{{ admin_route('parishes.create') }}" class="btn-primary">
        <x-icon name="plus" class="h-4 w-4" /> Nouvelle paroisse
    </a>
@endsection

@section('content')
    {{-- Filters --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <div class="relative flex-1">
            <span class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-[color:var(--color-ink-faint)]">
                <x-icon name="search" class="h-5 w-5" />
            </span>
            <input type="text" name="q" value="{{ $search }}" placeholder="Rechercher par nom, code, commune…"
                   class="input pl-10">
        </div>
        <select name="status" class="select sm:w-52" onchange="this.form.submit()">
            <option value="">Tous les statuts</option>
            @foreach(\App\Enums\ParishStatus::cases() as $s)
                <option value="{{ $s->value }}" @selected($status === $s->value)>{{ $s->label() }}</option>
            @endforeach
        </select>
        <button type="submit" class="btn-outline">Filtrer</button>
    </form>

    {{-- Table --}}
    <div class="card">
        <div class="table-wrap">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Paroisse</th>
                        <th>Code</th>
                        <th>Localisation</th>
                        <th>Fidèles</th>
                        <th>Statut</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($parishes as $parish)
                        <tr>
                            <td>
                                <div class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]">
                                        <x-icon name="church" class="h-5 w-5" />
                                    </span>
                                    <div class="min-w-0">
                                        <p class="font-semibold text-[color:var(--color-ink)]">{{ $parish->name }}</p>
                                        <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $parish->diocese }}</p>
                                    </div>
                                </div>
                            </td>
                            <td><span class="badge-muted font-mono">{{ $parish->code }}</span></td>
                            <td class="text-[color:var(--color-ink-soft)]">{{ $parish->commune ?? '—' }}{{ $parish->city ? ', '.$parish->city : '' }}</td>
                            <td><span class="font-semibold">{{ $parish->members_count }}</span></td>
                            <td>
                                @if($parish->status === \App\Enums\ParishStatus::Active)
                                    <span class="badge-success">● Active</span>
                                @else
                                    <span class="badge-muted">● Inactive</span>
                                @endif
                            </td>
                            <td>
                                <div class="flex items-center justify-end gap-1">
                                    <form method="POST" action="{{ admin_route('parishes.toggle', $parish) }}">
                                        @csrf @method('PATCH')
                                        <button type="submit" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]"
                                                title="{{ $parish->status === \App\Enums\ParishStatus::Active ? 'Désactiver' : 'Activer' }}">
                                            <x-icon name="check" class="h-4 w-4" />
                                        </button>
                                    </form>
                                    <a href="{{ admin_route('parishes.edit', $parish) }}" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)]" title="Modifier">
                                        <x-icon name="edit" class="h-4 w-4" />
                                    </a>
                                    <form method="POST" action="{{ admin_route('parishes.destroy', $parish) }}"
                                          onsubmit="return confirm('Supprimer définitivement « {{ $parish->name }} » ?');">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="rounded-lg p-2 text-red-500 hover:bg-red-50" title="Supprimer">
                                            <x-icon name="trash" class="h-4 w-4" />
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="flex flex-col items-center gap-2 py-12 text-center">
                                    <x-icon name="church" class="h-10 w-10 text-[color:var(--color-ink-faint)]" />
                                    <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucune paroisse trouvée.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-4">{{ $parishes->links() }}</div>
@endsection
