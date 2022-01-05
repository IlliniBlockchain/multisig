<script>
	import { Link } from 'svelte-routing'
	import { Button } from '../components'

	export let pendingHash = '0xg95bfasdfasdfasdf'
	export let name = 'Test name'
    export let executed = false
	export let description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum'
	export let { to, value, data } = { to: '0xa779987d89ssd', value: 10.5, data: '""'}
	export let signers = ['zayyan.eth', '0x6a59gg']
	export let signed = false
</script>

<div class='container'>
    <div class='top-bar'>
        <Link to='/'><div class='back-link'>← Back</div></Link>
        <div class={executed ? 'executed' : 'pending'}>
            {executed ? 'executed' : 'pending'}
        </div>
    </div>
	<h2 class='name'>{name}</h2>
	<p>{pendingHash}</p>
	<h3>Details</h3>
	<p>
		to: {to}
		<br>
		value: {value} ETH
		<br>
		data: {data}
	</p>
	<h3>Description</h3>
	<p>{description}</p>
	{#if signed }
		<div class='signed'>signed</div>
	{:else if !executed }
		<div class='sign'><Button>Sign Transaction</Button></div>
	{/if}
</div>

<style>
    .container {
        background-color: var(--dark-gray);
        min-height: 600px;
        border-radius: 12px;
        padding: 25px 35px;
		display: flex;
		flex-direction: column;
    }

    .top-bar {
        display: flex;
        justify-content: space-between;
		margin-bottom: 20px;
    }

    .back-link {
        width: fit-content;
        color: var(--light-text-color);
        padding: 10px 5px;
    }

    .pending, .executed {
		padding: 10px;
		border-radius: 10px;

		font-size: 0.9rem;
		font-weight: 600;
		text-transform: uppercase;

		padding: 8px 15px;
		width: fit-content;
		height: fit-content;
		/* margin: auto; */
	}

	.pending {
		border: solid 1px var(--orange);
		color: var(--orange);
	}

	.executed {
		border: solid 1px var(--green);
		color: var(--green);
	}

	.name {
		margin: 0;
	}

	h3 {
		margin: 0;
	}

	.sign {
		margin: auto;
		text-align: center;
	}

	.signed {
		padding: 10px;
		border-radius: 10px;
		border: 1px solid var(--light-text-color);

		font-size: 0.9rem;
		font-weight: 600;
		text-transform: uppercase;

		padding: 8px 15px;
		width: fit-content;
		height: fit-content;
		margin: auto;;
	}

</style>