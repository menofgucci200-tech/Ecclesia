<!DOCTYPE html>
<html lang="fr" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Tableau de bord') · Ecclesia</title>

    <link rel="icon" type="image/png" href="{{ asset('images/logo.png') }}">
    <link rel="apple-touch-icon" href="{{ asset('images/logo.png') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Merriweather:ital@0;1&display=swap" rel="stylesheet">

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="h-full font-sans text-[color:var(--color-ink)]">
<div x-data="{ open: false }" class="min-h-full">

    {{-- ============================ SIDEBAR ============================ --}}
    <div x-show="open" x-cloak @click="open = false" class="fixed inset-0 z-30 bg-navy-dark/50 lg:hidden"></div>

    <aside
        class="fixed inset-y-0 left-0 z-40 w-72 -translate-x-full transform bg-[color:var(--color-navy)] transition-transform duration-200 lg:translate-x-0"
        :class="open ? 'translate-x-0' : '-translate-x-full'"
    >
        <div class="flex h-full flex-col">
            {{-- Brand --}}
            <div class="px-4 pb-2 pt-6">
                <div class="rounded-2xl bg-white px-4 py-3 shadow-sm">
                    <img src="{{ asset('images/logo.png') }}" alt="Ecclesia" class="mx-auto h-24 w-auto">
                </div>
                <p class="mt-3 text-center text-[11px] font-semibold uppercase tracking-[0.2em] text-[color:var(--color-gold-light)]">Administration</p>
            </div>

            {{-- Nav --}}
            <nav class="flex-1 space-y-1 overflow-y-auto px-4 py-2">
                <p class="px-3 pb-2 pt-3 text-[10px] font-bold uppercase tracking-widest text-white/40">Pilotage</p>
                <a href="{{ admin_route('dashboard') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('dashboard')])>
                    <x-icon name="dashboard" class="h-5 w-5" /> Tableau de bord
                </a>

                <p class="px-3 pb-2 pt-5 text-[10px] font-bold uppercase tracking-widest text-white/40">Gestion</p>
                @if(auth()->user()->isSuperAdmin())
                    <a href="{{ admin_route('parishes.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('parishes.*')])>
                        <x-icon name="church" class="h-5 w-5" /> Paroisses
                    </a>
                    <a href="{{ admin_route('liturgies.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('liturgies.*')])>
                        <x-icon name="book" class="h-5 w-5" /> Liturgie
                    </a>
                    <a href="{{ admin_route('calendar.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('calendar.*')])>
                        <x-icon name="calendar" class="h-5 w-5" /> Calendrier
                    </a>
                @endif
                <a href="{{ admin_route('members.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('members.*')])>
                    <x-icon name="users" class="h-5 w-5" /> Fidèles
                </a>
                <a href="{{ admin_route('announcements.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('announcements.*')])>
                    <x-icon name="megaphone" class="h-5 w-5" /> Annonces
                </a>
                @if(auth()->user()->managedParishId() !== null)
                    <a href="{{ admin_route('mass-times.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('mass-times.*')])>
                        <x-icon name="calendar" class="h-5 w-5" /> Horaires de messe
                    </a>
                    <a href="{{ admin_route('events.index') }}" @class(['nav-link', 'nav-link-active' => admin_route_is('events.*')])>
                        <x-icon name="sparkles" class="h-5 w-5" /> Événements
                    </a>
                @endif
            </nav>

            {{-- User card --}}
            <div class="border-t border-white/10 p-4">
                <div class="flex items-center gap-3 rounded-xl bg-white/5 px-3 py-3">
                    <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[color:var(--color-gold)] text-sm font-bold text-[color:var(--color-navy-dark)]">
                        {{ strtoupper(mb_substr(auth()->user()->first_name, 0, 1).mb_substr(auth()->user()->last_name, 0, 1)) }}
                    </div>
                    <div class="min-w-0 flex-1 leading-tight">
                        <p class="truncate text-sm font-semibold text-white">{{ auth()->user()->fullName() }}</p>
                        <p class="truncate text-[11px] text-white/50">{{ auth()->user()->role->label() }}</p>
                    </div>
                    <form method="POST" action="{{ admin_route('logout') }}">
                        @csrf
                        <button type="submit" class="rounded-lg p-2 text-white/60 transition hover:bg-white/10 hover:text-white" title="Se déconnecter">
                            <x-icon name="logout" class="h-5 w-5" />
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </aside>

    {{-- ============================ MAIN ============================ --}}
    <div class="lg:pl-72">
        {{-- Topbar --}}
        <header class="sticky top-0 z-20 border-b border-[color:var(--color-border-soft)] bg-white/85 backdrop-blur">
            <div class="flex h-16 items-center gap-4 px-4 sm:px-6 lg:px-8">
                <button @click="open = true" class="rounded-lg p-2 text-[color:var(--color-ink-soft)] hover:bg-[color:var(--color-surface-muted)] lg:hidden">
                    <x-icon name="menu" class="h-6 w-6" />
                </button>
                <div class="min-w-0 flex-1">
                    <h1 class="truncate text-lg font-bold text-[color:var(--color-navy-dark)]">@yield('heading', 'Tableau de bord')</h1>
                    @hasSection('subheading')
                        <p class="truncate text-xs text-[color:var(--color-ink-soft)]">@yield('subheading')</p>
                    @endif
                </div>
                @yield('actions')
            </div>
        </header>

        {{-- Content --}}
        <main class="px-4 py-6 sm:px-6 lg:px-8">
            <x-flash />
            @yield('content')
        </main>
    </div>
</div>
</body>
</html>
