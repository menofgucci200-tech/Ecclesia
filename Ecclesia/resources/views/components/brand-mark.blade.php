@props(['class' => 'h-9 w-9'])

{{-- Ecclesia brand mark: a liturgical shield with a cross, navy + gold. --}}
<svg {{ $attributes->merge(['class' => $class]) }} viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <path d="M24 3 41 9v14c0 10.5-7.4 18.2-17 22-9.6-3.8-17-11.5-17-22V9l17-6Z" fill="#16335B"/>
    <path d="M24 3 41 9v14c0 10.5-7.4 18.2-17 22-9.6-3.8-17-11.5-17-22V9l17-6Z" stroke="#C6A02C" stroke-width="1.5"/>
    <path d="M22 13h4v6h6v4h-6v11h-4V23h-6v-4h6v-6Z" fill="#C6A02C"/>
</svg>
