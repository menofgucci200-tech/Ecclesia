@extends('admin.layouts.app')

@section('title', 'Demandes de messe')
@section('heading', 'Demandes de messe')
@section('subheading', 'Intentions demandées par les fidèles')

@section('content')
    {{-- Filters --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <select name="status" class="select sm:w-56" onchange="this.form.submit()">
            <option value="">Tous les statuts</option>
            @foreach(['pending' => 'En attente de paiement', 'paid' => 'Payée', 'scheduled' => 'Programmée', 'celebrated' => 'Célébrée'] as $value => $label)
                <option value="{{ $value }}" @selected($status === $value)>{{ $label }}</option>
            @endforeach
        </select>
        <button type="submit" class="btn-outline">Filtrer</button>
    </form>

    @if($intentions->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="book" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucune demande de messe pour l'instant.</p>
        </div>
    @else
        <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
            @foreach($intentions as $i)
                @php $st = $i->status; @endphp
                <div class="card card-pad">
                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0">
                            <span class="badge-gold">{{ $i->intention_type->label() }}</span>
                            <h3 class="mt-2 text-base font-bold text-[color:var(--color-navy-dark)]">{{ $i->intention }}</h3>
                        </div>
                        <span @class([
                            'shrink-0',
                            'badge-success' => in_array($st, ['scheduled', 'celebrated'], true),
                            'badge-gold' => $st === 'paid',
                            'badge-muted' => $st === 'pending',
                        ])>
                            {{ ['pending' => 'À payer', 'paid' => 'Payée', 'scheduled' => 'Programmée', 'celebrated' => 'Célébrée'][$st] ?? $st }}
                        </span>
                    </div>

                    <div class="mt-3 grid grid-cols-2 gap-2 text-sm">
                        <div>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">Fidèle</p>
                            <p class="font-medium">{{ optional($i->user)->fullName() ?? '—' }}</p>
                        </div>
                        <div>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">Date souhaitée</p>
                            <p class="font-medium">{{ $i->mass_date ? $i->mass_date->translatedFormat('d M Y') : 'Non précisée' }}</p>
                        </div>
                        <div>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">Offrande</p>
                            <p class="font-medium">{{ number_format($i->amount, 0, ',', ' ') }} F</p>
                        </div>
                        <div>
                            <p class="text-xs text-[color:var(--color-ink-soft)]">Demandée le</p>
                            <p class="font-medium">{{ $i->created_at->translatedFormat('d M Y') }}</p>
                        </div>
                    </div>

                    @if($i->note)
                        <p class="mt-3 rounded-lg bg-[color:var(--color-surface-muted)] p-3 text-sm text-[color:var(--color-ink-soft)]">{{ $i->note }}</p>
                    @endif

                    @if($st !== 'pending')
                        <form method="POST" action="{{ admin_route('mass-intentions.status', $i) }}" class="mt-4 flex items-center gap-2 border-t border-[color:var(--color-border-soft)] pt-4">
                            @csrf @method('PATCH')
                            <select name="status" class="select flex-1">
                                <option value="paid" @selected($st === 'paid')>Payée</option>
                                <option value="scheduled" @selected($st === 'scheduled')>Programmée</option>
                                <option value="celebrated" @selected($st === 'celebrated')>Célébrée</option>
                            </select>
                            <button type="submit" class="btn-primary">
                                <x-icon name="check" class="h-4 w-4" /> Mettre à jour
                            </button>
                        </form>
                    @else
                        <p class="mt-4 border-t border-[color:var(--color-border-soft)] pt-4 text-xs text-[color:var(--color-ink-faint)]">
                            En attente du paiement du fidèle.
                        </p>
                    @endif
                </div>
            @endforeach
        </div>
        <div class="mt-6">{{ $intentions->links() }}</div>
    @endif
@endsection
