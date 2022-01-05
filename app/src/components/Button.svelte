<script>
	export let blue;
</script>

<button class={['btn', blue && 'blue'].join(' ')}>
    <slot/>
</button>

<style>
    .btn {
		background-color: var(--orange);
		color: white;
		border-radius: 12px;
		width: fit-content;
        height: fit-content;
		padding: 10px 15px;
		font-size: 1rem;
		font-family: inherit;
		font-weight: 600;
		border: none;
		transition: 0.1s;
	}

    .btn:hover {
		background-color: var(--light-orange);
		cursor: pointer;
	}

	.blue {
		background-color: var(--blue);
	}
	
	.blue:hover {
		background-color: var(--light-blue);
	}
</style>