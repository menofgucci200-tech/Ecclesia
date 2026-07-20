<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('avatar')->nullable()->after('email');
            $table->json('preferences')->nullable()->after('avatar');
        });

        Schema::table('movement_posts', function (Blueprint $table) {
            $table->string('video_url')->nullable()->after('image');
        });

        // Fundraising campaigns (dons, cotisations, quêtes) run by the parish.
        Schema::create('campaigns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('type', 20)->default('don');       // don | cotisation | quete
            $table->unsignedBigInteger('target_amount')->nullable();  // objectif (F CFA)
            $table->unsignedBigInteger('collected_amount')->default(0);
            $table->string('image')->nullable();
            $table->boolean('is_active')->default(true);
            $table->date('ends_at')->nullable();
            $table->timestamps();
        });

        // Pledges (promesses de don) — record intent, no real payment yet.
        Schema::create('campaign_pledges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('amount');
            $table->string('status', 20)->default('pledged');  // pledged | paid
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('campaign_pledges');
        Schema::dropIfExists('campaigns');
        Schema::table('movement_posts', fn (Blueprint $t) => $t->dropColumn('video_url'));
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn(['avatar', 'preferences']));
    }
};
