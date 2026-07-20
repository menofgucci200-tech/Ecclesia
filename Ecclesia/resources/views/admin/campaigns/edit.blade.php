@extends('admin.layouts.app')
@section('title', 'Modifier la collecte')
@section('heading', $campaign->title)
@section('subheading', 'Modifier la collecte')
@section('actions')<a href="{{ admin_route('campaigns.index') }}" class="btn-ghost"><x-icon name="chevron-left" class="h-4 w-4" /> Retour</a>@endsection
@section('content')@include('admin.campaigns._form')@endsection
