@props(['status'])

@php
    $map = [
        'active'    => ['badge-success', '● Actif'],
        'inactive'  => ['badge-muted', '● Inactif'],
        'suspended' => ['badge-danger', '● Suspendu'],
    ];
    $value = $status instanceof \BackedEnum ? $status->value : $status;
    [$class, $text] = $map[$value] ?? ['badge-muted', ucfirst((string) $value)];
@endphp

<span class="{{ $class }}">{{ $text }}</span>
