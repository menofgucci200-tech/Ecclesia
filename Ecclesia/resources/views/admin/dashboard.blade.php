@extends('admin.layouts.app')

@section('title', 'Tableau de bord')
@section('heading', 'Tableau de bord')
@section('subheading', $scopeParish ? 'Paroisse '.$scopeParish->name : "Vue d'ensemble de la plateforme")

@section('content')
    {{-- KPI cards --}}
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <x-stat-card label="Fidèles" :value="number_format($totalMembers, 0, ',', ' ')"
                     icon="users" tone="navy"
                     :hint="$activeMembers.' actifs'" />
        <x-stat-card label="Nouveaux ce mois-ci" :value="number_format($newThisMonth, 0, ',', ' ')"
                     icon="trend-up" tone="success"
                     hint="inscriptions du mois" />
        <x-stat-card label="Annonces publiées" :value="number_format($publishedAnnouncements, 0, ',', ' ')"
                     icon="megaphone" tone="gold"
                     :hint="$totalAnnouncements.' au total'" />
        @if($scopeParish)
            <x-stat-card label="Paroisse" :value="$scopeParish->commune ?? $scopeParish->name"
                         icon="church" tone="info" :hint="$scopeParish->diocese" />
        @else
            <x-stat-card label="Paroisses" :value="number_format($totalParishes, 0, ',', ' ')"
                         icon="church" tone="info" :hint="$activeParishes.' actives'" />
        @endif
    </div>

    <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-3">
        {{-- Growth chart --}}
        <div class="card card-pad lg:col-span-2">
            <div class="mb-4 flex items-center justify-between">
                <div>
                    <h3 class="text-base font-bold">Nouveaux fidèles</h3>
                    <p class="text-xs text-[color:var(--color-ink-soft)]">6 derniers mois</p>
                </div>
                <span class="badge-navy">{{ array_sum($growth['values']) }} au total</span>
            </div>

            @php $max = max(1, max($growth['values'])); @endphp
            <div class="flex h-52 items-stretch gap-3 sm:gap-5">
                @foreach($growth['labels'] as $i => $label)
                    <div class="flex h-full flex-1 flex-col items-center gap-2">
                        <div class="flex w-full flex-1 items-end">
                            <div class="group relative w-full rounded-t-lg bg-[color:var(--color-navy)] transition-all hover:bg-[color:var(--color-gold)]"
                                 style="height: {{ max(4, (int) round($growth['values'][$i] / $max * 100)) }}%">
                                <span class="absolute -top-6 left-1/2 -translate-x-1/2 rounded bg-[color:var(--color-navy-dark)] px-1.5 py-0.5 text-[10px] font-semibold text-white opacity-0 transition group-hover:opacity-100">
                                    {{ $growth['values'][$i] }}
                                </span>
                            </div>
                        </div>
                        <span class="text-[11px] font-medium text-[color:var(--color-ink-soft)]">{{ $label }}</span>
                    </div>
                @endforeach
            </div>
        </div>

        {{-- Distribution / quick actions --}}
        <div class="card card-pad">
            @if($scopeParish === null && $membersByParish->isNotEmpty())
                <h3 class="mb-4 text-base font-bold">Top paroisses</h3>
                <div class="space-y-3">
                    @php $topMax = max(1, $membersByParish->max('members_count')); @endphp
                    @foreach($membersByParish as $p)
                        <div>
                            <div class="mb-1 flex items-center justify-between text-sm">
                                <span class="truncate font-medium text-[color:var(--color-ink)]">{{ $p->name }}</span>
                                <span class="ml-2 shrink-0 text-xs font-semibold text-[color:var(--color-ink-soft)]">{{ $p->members_count }}</span>
                            </div>
                            <div class="h-2 overflow-hidden rounded-full bg-[color:var(--color-surface-muted)]">
                                <div class="h-full rounded-full bg-[color:var(--color-gold)]" style="width: {{ (int) round($p->members_count / $topMax * 100) }}%"></div>
                            </div>
                        </div>
                    @endforeach
                </div>
            @else
                <h3 class="mb-4 text-base font-bold">Actions rapides</h3>
                <div class="space-y-3">
                    <a href="{{ admin_route('announcements.create') }}" class="btn-gold w-full">
                        <x-icon name="plus" class="h-4 w-4" /> Nouvelle annonce
                    </a>
                    <a href="{{ admin_route('members.index') }}" class="btn-outline w-full">
                        <x-icon name="users" class="h-4 w-4" /> Gérer les fidèles
                    </a>
                </div>
            @endif
        </div>
    </div>

    {{-- Recent activity --}}
    <div class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-2">
        {{-- Recent announcements --}}
        <div class="card">
            <div class="flex items-center justify-between border-b border-[color:var(--color-border-soft)] px-5 py-4">
                <h3 class="text-base font-bold">Dernières annonces</h3>
                <a href="{{ admin_route('announcements.index') }}" class="text-sm font-semibold text-[color:var(--color-navy-light)] hover:underline">Tout voir</a>
            </div>
            <div class="divide-y divide-[color:var(--color-border-soft)]">
                @forelse($recentAnnouncements as $a)
                    <div class="flex items-center gap-3 px-5 py-3.5">
                        <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-[color:var(--color-gold-soft)] text-[color:var(--color-gold)]">
                            <x-icon name="megaphone" class="h-5 w-5" />
                        </span>
                        <div class="min-w-0 flex-1">
                            <p class="truncate text-sm font-semibold text-[color:var(--color-ink)]">{{ $a->title }}</p>
                            <p class="truncate text-xs text-[color:var(--color-ink-soft)]">
                                {{ $a->category->label() }}@if($a->parish) · {{ $a->parish->name }}@endif
                            </p>
                        </div>
                        <span class="shrink-0 text-xs text-[color:var(--color-ink-faint)]">
                            {{ optional($a->published_at)->translatedFormat('d M') ?? 'Brouillon' }}
                        </span>
                    </div>
                @empty
                    <p class="px-5 py-8 text-center text-sm text-[color:var(--color-ink-soft)]">Aucune annonce pour le moment.</p>
                @endforelse
            </div>
        </div>

        {{-- Recent members --}}
        <div class="card">
            <div class="flex items-center justify-between border-b border-[color:var(--color-border-soft)] px-5 py-4">
                <h3 class="text-base font-bold">Nouveaux fidèles</h3>
                <a href="{{ admin_route('members.index') }}" class="text-sm font-semibold text-[color:var(--color-navy-light)] hover:underline">Tout voir</a>
            </div>
            <div class="divide-y divide-[color:var(--color-border-soft)]">
                @forelse($recentMembers as $m)
                    <div class="flex items-center gap-3 px-5 py-3.5">
                        <span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[color:var(--color-navy)]/10 text-xs font-bold text-[color:var(--color-navy)]">
                            {{ strtoupper(mb_substr($m->first_name, 0, 1).mb_substr($m->last_name, 0, 1)) }}
                        </span>
                        <div class="min-w-0 flex-1">
                            <p class="truncate text-sm font-semibold text-[color:var(--color-ink)]">{{ $m->fullName() }}</p>
                            <p class="truncate text-xs text-[color:var(--color-ink-soft)]">{{ optional($m->parish)->name ?? 'Sans paroisse' }}</p>
                        </div>
                        <span class="shrink-0 text-xs text-[color:var(--color-ink-faint)]">{{ $m->created_at->translatedFormat('d M') }}</span>
                    </div>
                @empty
                    <p class="px-5 py-8 text-center text-sm text-[color:var(--color-ink-soft)]">Aucun fidèle pour le moment.</p>
                @endforelse
            </div>
        </div>
    </div>
@endsection
