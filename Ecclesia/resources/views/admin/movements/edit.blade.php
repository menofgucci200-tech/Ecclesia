@extends('admin.layouts.app')
@section('title', 'Modifier le mouvement')
@section('heading', $movement->name)
@section('subheading', 'Modifier le mouvement')
@section('actions')
    <a href="{{ admin_route('movements.index') }}" class="btn-ghost"><x-icon name="chevron-left" class="h-4 w-4" /> Retour</a>
@endsection
@section('content')
    @include('admin.movements._form')
@endsection
