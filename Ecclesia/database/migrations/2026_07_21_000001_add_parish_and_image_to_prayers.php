<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('prayers', function (Blueprint $table) {
            // Null = common library (managed by super-admin, visible to all).
            // Set = specific to that parish (managed by the parish admin).
            $table->foreignId('parish_id')->nullable()->after('id')->constrained()->nullOnDelete();
            $table->string('image')->nullable()->after('reference');
        });
    }

    public function down(): void
    {
        Schema::table('prayers', function (Blueprint $table) {
            $table->dropConstrainedForeignId('parish_id');
            $table->dropColumn('image');
        });
    }
};
