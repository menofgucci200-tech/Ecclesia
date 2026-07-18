@extends('admin.layouts.app')

@section('title', 'Nouvelle paroisse')
@section('heading', 'Nouvelle paroisse')
@section('subheading', 'Ajouter une paroisse au répertoire')

@section('actions')
    <a href="{{ admin_route('parishes.index') }}" class="btn-ghost">
        <x-icon name="chevron-left" class="h-4 w-4" /> Retour
    </a>
@endsection

@section('content')
    <div class="mx-auto max-w-3xl">
        @include('admin.parishes._form')
    </div>
@endsection
