@extends('admin.layouts.app')
@section('title', 'Nouvelle collecte')
@section('heading', 'Nouvelle collecte')
@section('actions')<a href="{{ admin_route('campaigns.index') }}" class="btn-ghost"><x-icon name="chevron-left" class="h-4 w-4" /> Retour</a>@endsection
@section('content')@include('admin.campaigns._form')@endsection
