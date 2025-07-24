import discord
from discord.ext import commands
import aiosqlite
import random

intents = discord.Intents.default()
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

DB_NAME = "economy.db"

@bot.event
async def on_ready():
    async with aiosqlite.connect(DB_NAME) as db:
        await db.execute('''CREATE TABLE IF NOT EXISTS users (
                            user_id INTEGER PRIMARY KEY,
                            coins INTEGER DEFAULT 100)''')
        await db.commit()
    print(f"{bot.user} is online!")

# Helper: Ensure user exists
async def ensure_user(user_id):
    async with aiosqlite.connect(DB_NAME) as db:
        await db.execute("INSERT OR IGNORE INTO users (user_id) VALUES (?)", (user_id,))
        await db.commit()

# 🎰 Gambling Commands

@bot.command()
async def coinflip(ctx, bet: int):
    await ensure_user(ctx.author.id)
    async with aiosqlite.connect(DB_NAME) as db:
        cursor = await db.execute("SELECT coins FROM users WHERE user_id = ?", (ctx.author.id,))
        row = await cursor.fetchone()
        if not row or row[0] < bet:
            return await ctx.send("Not enough coins!")
        result = random.choice(["heads", "tails"])
        win = random.choice([True, False])
        new_balance = row[0] + bet if win else row[0] - bet
        await db.execute("UPDATE users SET coins = ? WHERE user_id = ?", (new_balance, ctx.author.id))
        await db.commit()
        await ctx.send(f"You {'won' if win else 'lost'}! Coin landed on {result}. New balance: {new_balance}")

@bot.command()
async def roulette(ctx, color: str, bet: int):
    colors = {"red": 2, "black": 2, "green": 14}
    if color not in colors:
        return await ctx.send("Choose red, black, or green.")

    await ensure_user(ctx.author.id)
    async with aiosqlite.connect(DB_NAME) as db:
        cursor = await db.execute("SELECT coins FROM users WHERE user_id = ?", (ctx.author.id,))
        row = await cursor.fetchone()
        if row[0] < bet:
            return await ctx.send("Not enough coins!")

        result = random.choices(["red", "black", "green"], weights=[18, 18, 1])[0]
        multiplier = colors[color] if color == result else 0
        winnings = bet * multiplier
        new_balance = row[0] - bet + winnings
        await db.execute("UPDATE users SET coins = ? WHERE user_id = ?", (new_balance, ctx.author.id))
        await db.commit()
        await ctx.send(f"Roulette landed on {result}. You {'won' if multiplier else 'lost'}! New balance: {new_balance}")

# 💰 Economy Commands

@bot.command()
async def balance(ctx, member: discord.Member = None):
    member = member or ctx.author
    await ensure_user(member.id)
    async with aiosqlite.connect(DB_NAME) as db:
        cursor = await db.execute("SELECT coins FROM users WHERE user_id = ?", (member.id,))
        row = await cursor.fetchone()
        await ctx.send(f"{member.display_name} has {row[0]} coins.")

@bot.command()
async def leaderboard(ctx):
    async with aiosqlite.connect(DB_NAME) as db:
        cursor = await db.execute("SELECT user_id, coins FROM users ORDER BY coins DESC LIMIT 5")
        rows = await cursor.fetchall()
        message = "**Leaderboard:**\n"
        for i, (user_id, coins) in enumerate(rows, 1):
            user = await bot.fetch_user(user_id)
            message += f"{i}. {user.name} - {coins} coins\n"
        await ctx.send(message)

# 🔨 Moderation

@bot.command()
@commands.has_permissions(ban_members=True)
async def ban(ctx, member: discord.Member, *, reason="No reason"):
    await member.ban(reason=reason)
    await ctx.send(f"{member} was banned for: {reason}")

@bot.command()
@commands.has_permissions(kick_members=True)
async def kick(ctx, member: discord.Member, *, reason="No reason"):
    await member.kick(reason=reason)
    await ctx.send(f"{member} was kicked for: {reason}")

@bot.command()
@commands.has_permissions(moderate_members=True)
async def mute(ctx, member: discord.Member, duration: int):
    await member.timeout(discord.utils.utcnow() + discord.timedelta(minutes=duration))
    await ctx.send(f"{member} has been muted for {duration} minutes.")

# 🛠 Error handling

@bot.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.MissingPermissions):
        await ctx.send("You don't have permission for that.")
    elif isinstance(error, commands.MissingRequiredArgument):
        await ctx.send("Missing argument.")
    elif isinstance(error, commands.CommandNotFound):
        pass
    else:
        raise error

# 🚀 Run bot
bot.run("YOUR_BOT_TOKEN")
