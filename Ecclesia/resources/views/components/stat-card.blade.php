@props(['label', 'value', 'icon' => 'sparkles', 'hint' => null, 'tone' => 'navy'])

@php
    $tones = [
        'navy' => 'bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]',
        'gold' => 'bg-[color:var(--color-gold-soft)] text-[color:var(--color-gold)]',
        'success' => 'bg-emerald-50 text-emerald-600',
        'info' => 'bg-blue-50 text-blue-600',
    ];
    $toneClass = $tones[$tone] ?? $tones['navy'];
@endphp

<div class="card card-pad">
    <div class="flex items-start justify-between gap-3">
        <div>
            <p class="text-xs font-bold uppercase tracking-wide text-[color:var(--color-ink-soft)]">{{ $label }}</p>
            <p class="mt-2 text-3xl font-extrabold text-[color:var(--color-navy-dark)]">{{ $value }}</p>
            @if($hint)
                <p class="mt-1 text-xs text-[color:var(--color-ink-soft)]">{{ $hint }}</p>
            @endif
        </div>
        <span class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl {{ $toneClass }}">
            <x-icon :name="$icon" class="h-6 w-6" />
        </span>
    </div>
</div>
