@extends('admin.layouts.app')
@section('title', 'Nouvel événement')
@section('heading', 'Nouvel événement')
@section('actions')
    <a href="{{ admin_route('events.index') }}" class="btn-ghost"><x-icon name="chevron-left" class="h-4 w-4" /> Retour</a>
@endsection
@section('content')
    @include('admin.events._form')
@endsection
