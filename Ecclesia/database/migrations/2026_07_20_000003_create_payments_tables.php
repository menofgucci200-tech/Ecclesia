<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique();
            $table->foreignId('parish_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('type')->index();
            $table->string('label');
            $table->unsignedInteger('amount');
            $table->string('currency', 8)->default('XOF');
            $table->string('status')->default('pending')->index();
            $table->string('channel')->nullable();
            $table->string('operator')->nullable();
            $table->string('cinetpay_token')->nullable();
            $table->text('payment_url')->nullable();
            $table->json('meta')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });

        Schema::create('mass_intentions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('parish_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('intention_type')->default('autre');
            $table->text('intention');
            $table->date('mass_date')->nullable();
            $table->text('note')->nullable();
            $table->unsignedInteger('amount')->default(0);
            // pending (awaiting payment) → paid → scheduled → celebrated
            $table->string('status')->default('pending')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mass_intentions');
        Schema::dropIfExists('payments');
    }
};
