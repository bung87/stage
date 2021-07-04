name: Test

on:
  push:
    paths-ignore: 
      - README.md
  pull_request:
    paths-ignore: 
      - README.md

jobs:
  test:
    runs-on: ${{ matrix.os }}
    continue-on-error: ${{ matrix.experimental }}
    strategy:
      fail-fast: false
      matrix:
        os:
          - ubuntu-latest
        experimental: [false]
        nim-version:
          - stable
          # - devel
        include:
          - os: windows-latest
            experimental: true
            nim-version: stable
            #   - stable
            #   - devel
        # exclude:
          - os: macos-latest
            experimental: true
            nim-version: stable
            #   - stable
            #   - devel
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Cache choosenim
      id: cache-choosenim
      uses: actions/cache@v1
      with:
        path: ~/.choosenim
        key: ${{ runner.os }}-choosenim-${{ matrix.nim-version}}

    - name: Cache nimble
      id: cache-nimble
      uses: actions/cache@v1
      with:
        path: ~/.nimble
        key: ${{ runner.os }}-nimble-${{ matrix.nim-version}}-${{ hashFiles('*.nimble') }}

    - name: Setup nim
      uses: jiro4989/setup-nim-action@v1.3.2
      with:
        nim-version: ${{ matrix.nim-version }}

    - name: Install Packages
      run: nimble install -d -y
    - name: Install slim
      run: nimble install slim -y
    - name: Test
      run: slim --silent test 