@extends('admin.layouts.app')

@section('title', 'Nouvelle annonce')
@section('heading', 'Nouvelle annonce')
@section('subheading', 'Publier dans le fil paroissial')

@section('actions')
    <a href="{{ admin_route('announcements.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@section('content')
    @include('admin.announcements._form')
@endsection
