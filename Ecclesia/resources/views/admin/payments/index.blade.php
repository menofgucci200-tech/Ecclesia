@extends('admin.layouts.app')

@section('title', 'Paiements')
@section('heading', 'Paiements')
@section('subheading', 'Dons, quêtes, demandes de messe et casuel (CinetPay)')

@section('content')
    {{-- Stats --}}
    <div class="mb-5 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div class="card card-pad">
            <p class="text-xs font-bold uppercase tracking-wide text-[color:var(--color-ink-soft)]">Total encaissé</p>
            <p class="mt-1 text-2xl font-extrabold text-[color:var(--color-navy)]">{{ number_format($totalCollected, 0, ',', ' ') }} F</p>
        </div>
        <div class="card card-pad">
            <p class="text-xs font-bold uppercase tracking-wide text-[color:var(--color-ink-soft)]">Paiements réussis</p>
            <p class="mt-1 text-2xl font-extrabold text-[color:var(--color-navy)]">{{ $paidCount }}</p>
        </div>
    </div>

    {{-- Filters --}}
    <form method="GET" class="card card-pad mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <select name="type" class="select sm:w-56" onchange="this.form.submit()">
            <option value="">Tous les types</option>
            @foreach($types as $t)
                <option value="{{ $t->value }}" @selected($type === $t->value)>{{ $t->label() }}</option>
            @endforeach
        </select>
        <select name="status" class="select sm:w-48" onchange="this.form.submit()">
            <option value="">Tous les statuts</option>
            @foreach($statuses as $s)
                <option value="{{ $s->value }}" @selected($status === $s->value)>{{ $s->label() }}</option>
            @endforeach
        </select>
        <button type="submit" class="btn-outline">Filtrer</button>
    </form>

    @if($payments->isEmpty())
        <div class="card card-pad flex flex-col items-center gap-3 py-16 text-center">
            <x-icon name="credit-card" class="h-12 w-12 text-[color:var(--color-ink-faint)]" />
            <p class="text-sm font-medium text-[color:var(--color-ink-soft)]">Aucun paiement pour l'instant.</p>
        </div>
    @else
        <div class="card overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b border-[color:var(--color-border-soft)] text-left text-xs uppercase tracking-wide text-[color:var(--color-ink-soft)]">
                            <th class="px-4 py-3 font-semibold">Type</th>
                            <th class="px-4 py-3 font-semibold">Fidèle</th>
                            <th class="px-4 py-3 font-semibold">Référence</th>
                            <th class="px-4 py-3 text-right font-semibold">Montant</th>
                            <th class="px-4 py-3 font-semibold">Statut</th>
                            <th class="px-4 py-3 font-semibold">Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($payments as $p)
                            <tr class="border-b border-[color:var(--color-border-soft)] last:border-0">
                                <td class="px-4 py-3">
                                    <span class="font-semibold text-[color:var(--color-navy-dark)]">{{ $p->type->label() }}</span>
                                    @if($p->massIntention)
                                        <p class="text-xs text-[color:var(--color-ink-soft)]">{{ \Illuminate\Support\Str::limit($p->massIntention->intention, 40) }}</p>
                                        @if($p->massIntention->mass_date)
                                            <p class="text-xs text-[color:var(--color-ink-faint)]">🗓 {{ $p->massIntention->mass_date->translatedFormat('d M Y') }}</p>
                                        @endif
                                    @elseif(!empty($p->meta['scheduled_for']))
                                        <p class="text-xs text-[color:var(--color-ink-faint)]">🗓 {{ \Illuminate\Support\Carbon::parse($p->meta['scheduled_for'])->translatedFormat('d M Y') }}</p>
                                    @endif
                                </td>
                                <td class="px-4 py-3">{{ optional($p->user)->fullName() ?? '—' }}</td>
                                <td class="px-4 py-3 font-mono text-xs text-[color:var(--color-ink-soft)]">{{ $p->reference }}</td>
                                <td class="px-4 py-3 text-right font-bold">{{ number_format($p->amount, 0, ',', ' ') }} F</td>
                                <td class="px-4 py-3">
                                    @php $st = $p->status->value; @endphp
                                    <span @class([
                                        'badge-success' => $st === 'paid',
                                        'badge-gold' => $st === 'pending',
                                        'badge-danger' => $st === 'failed',
                                        'badge-muted' => in_array($st, ['cancelled', 'expired'], true),
                                    ])>{{ $p->status->label() }}</span>
                                </td>
                                <td class="px-4 py-3 text-[color:var(--color-ink-soft)]">{{ $p->created_at->translatedFormat('d M Y H:i') }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
        <div class="mt-6">{{ $payments->links() }}</div>
    @endif
@endsection
