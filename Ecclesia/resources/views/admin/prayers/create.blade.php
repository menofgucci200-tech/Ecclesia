@extends('admin.layouts.app')

@section('title', 'Nouveau contenu')
@section('heading', 'Nouveau contenu')
@section('subheading', 'Prière, chapelet, neuvaine ou litanie')

@section('actions')
    <a href="{{ admin_route('prayers.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@section('content')
    @include('admin.prayers._form')
@endsection
