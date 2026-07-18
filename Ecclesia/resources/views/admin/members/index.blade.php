@extends('admin.layouts.app')

@section('title', 'Fidèles')
@section('heading', 'Fidèles')
@section('subheading', $members->total().' fidèle(s)')

@section('content')
    {{-- Filters --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <div class="relative flex-1">
            <span class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-[color:var(--color-ink-faint)]">
                <x-icon name="search" class="h-5 w-5" />
            </span>
            <input type="text" name="q" value="{{ $search }}" placeholder="Nom, téléphone, e-mail…" class="input pl-10">
        </div>
        @if($scopeParishId === null)
            <select name="parish" class="select sm:w-56" onchange="this.form.submit()">
                <option value="">Toutes les paroisses</option>
                @foreach($parishes as $p)
                    <option value="{{ $p->id }}" @selected((string) $parishFilter === (string) $p->id)>{{ $p->name }}</option>
                @endforeach
            </select>
        @endif
        <select name="status" class="select sm:w-44" onchange="this.form.submit()">
            <option value="">Tous les statuts</option>
            @foreach(\App\Enums\UserStatus::cases() as $s)
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
                        <th>Fidèle</th>
                        <th>Contact</th>
                        <th>Paroisse</th>
                        <th>Inscrit le</th>
                        <th>Statut</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($members as $member)
                        <tr>
                            <td>
                                <div class="flex items-center gap-3">
                                    <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[color:var(--color-navy)]/10 text-xs font-bold text-[color:var(--color-navy)]">
                                        {{ strtoupper(mb_substr($member->first_name, 0, 1).mb_substr($member->last_name, 0, 1)) }}
                                    </span>
                                    <div class="min-w-0">
                                        <p class="font-semibold text-[color:var(--color-ink)]">{{ $member->fullName() }}</p>
                                        <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $member->gender?->label() }}</p>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <p class="text-[color:var(--color-ink)]">{{ $member->phone }}</p>
                                <p class="text-xs text-[color:var(--color-ink-soft)]">{{ $member->email ?? '—' }}</p>
                            </td>
                            <td class="text-[color:var(--color-ink-soft)]">{{ optional($member->parish)->name ?? '—' }}</td>
                            <td class="text-[color:var(--color-ink-soft)]">{{ $member->created_at->translatedFormat('d M Y') }}</td>
                            <td><x-status-badge :status="$member->status" /></td>
                            <td class="text-right">
                                <a href="{{ admin_route('members.show', $member) }}" class="btn-outline btn-sm">
                                    <x-icon name="eye" class="h-4 w-4" /> Voir
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6">
                                <div class="flex flex-col items-center gap-2 py-12 text-center">
                                    <x-icon name="users" class="h-10 w-10 text-[color:var(--color-ink-faint)]" />
                                    <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucun fidèle trouvé.</p>
                                </div>
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-4">{{ $members->links() }}</div>
@endsection
