@extends('movement.layouts.app')
@section('title', 'Modifier l\'annonce')
@section('heading', 'Modifier l\'annonce')
@section('actions')<a href="{{ route('mouvement.posts.index') }}" class="btn-ghost"><x-icon name="chevron-left" class="h-4 w-4" /> Retour</a>@endsection
@section('content')@include('movement.posts._form')@endsection
