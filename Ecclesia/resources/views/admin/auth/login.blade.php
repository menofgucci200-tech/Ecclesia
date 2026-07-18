<!DOCTYPE html>
<html lang="fr" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    @php($isSuper = ($area ?? 'admin') === 'super')
    <title>Connexion · Ecclesia {{ $isSuper ? 'Super Admin' : 'Espace Paroisse' }}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Merriweather:ital@0;1&display=swap" rel="stylesheet">

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="h-full font-sans">
<div class="grid min-h-full lg:grid-cols-2">

    {{-- Brand panel --}}
    <div class="relative hidden overflow-hidden bg-[color:var(--color-navy)] lg:block">
        <div class="absolute inset-0 opacity-[0.07]"
             style="background-image: radial-gradient(circle at 1px 1px, #fff 1px, transparent 0); background-size: 22px 22px;"></div>
        <div class="absolute -right-24 -top-24 h-96 w-96 rounded-full bg-[color:var(--color-navy-light)]/40 blur-3xl"></div>
        <div class="absolute -bottom-24 -left-24 h-96 w-96 rounded-full bg-[color:var(--color-gold)]/20 blur-3xl"></div>

        <div class="relative flex h-full flex-col justify-between p-12">
            <div class="flex items-center gap-3">
                <x-brand-mark class="h-11 w-11" />
                <div class="leading-tight">
                    <p class="font-serif text-xl font-bold text-white">Ecclesia</p>
                    <p class="text-[11px] font-medium uppercase tracking-[0.18em] text-[color:var(--color-gold-light)]">{{ $isSuper ? 'Super administration' : 'Espace paroisse' }}</p>
                </div>
            </div>

            <div class="max-w-md">
                <p class="font-serif text-3xl italic leading-snug text-white">
                    « Là où deux ou trois sont réunis en mon nom, je suis au milieu d'eux. »
                </p>
                <p class="mt-4 text-sm text-white/60">Matthieu 18, 20</p>
            </div>

            <p class="text-sm text-white/50">Gérez vos paroisses, vos fidèles et le fil paroissial en un seul endroit.</p>
        </div>
    </div>

    {{-- Form panel --}}
    <div class="flex items-center justify-center px-6 py-12">
        <div class="w-full max-w-sm">
            <div class="mb-8 flex items-center gap-3 lg:hidden">
                <x-brand-mark class="h-10 w-10" />
                <p class="font-serif text-xl font-bold text-[color:var(--color-navy-dark)]">Ecclesia</p>
            </div>

            <span class="mb-3 inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold {{ $isSuper ? 'bg-[color:var(--color-gold-soft)] text-[color:var(--color-navy-dark)]' : 'bg-[color:var(--color-navy)]/10 text-[color:var(--color-navy)]' }}">
                {{ $isSuper ? '★ Super administrateur' : '⛪ Administrateur de paroisse' }}
            </span>
            <h1 class="text-2xl font-extrabold text-[color:var(--color-navy-dark)]">Bienvenue</h1>
            <p class="mt-1 text-sm text-[color:var(--color-ink-soft)]">
                {{ $isSuper ? "Espace réservé à l'administration de la plateforme." : "Connectez-vous à l'espace d'administration de votre paroisse." }}
            </p>

            @if ($errors->has('email'))
                <div class="mt-5 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                    {{ $errors->first('email') }}
                </div>
            @endif

            <form method="POST" action="{{ route(($area ?? 'admin').'.login.attempt') }}" class="mt-6 space-y-5">
                @csrf
                <div>
                    <label for="email" class="field-label">Adresse e-mail</label>
                    <input id="email" name="email" type="email" value="{{ old('email') }}" required autofocus
                           class="input" placeholder="vous@paroisse.ci">
                </div>
                <div>
                    <label for="password" class="field-label">Mot de passe</label>
                    <input id="password" name="password" type="password" required
                           class="input" placeholder="••••••••">
                </div>
                <label class="flex items-center gap-2 text-sm text-[color:var(--color-ink-soft)]">
                    <input type="checkbox" name="remember" class="h-4 w-4 rounded border-[color:var(--color-border-strong)] text-[color:var(--color-navy)]">
                    Rester connecté
                </label>
                <button type="submit" class="btn-primary w-full py-3">Se connecter</button>
            </form>

            <p class="mt-8 text-center text-xs text-[color:var(--color-ink-faint)]">
                © {{ date('Y') }} Ecclesia — Tous droits réservés.
            </p>
        </div>
    </div>
</div>
</body>
</html>
