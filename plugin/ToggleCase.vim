" Name: ToggleCase
" Version: 0.1
" Author: Hideaki Tanabe <tanablog@gmail.com>
" Caution: this script need perl interface (compile with +perlinterp)
" Usage:
" :call ToggleCase() or assign key for example below
" nnoremap <silent> <C-k>  :<C-u>call ToggleCase()<CR>
" word under cusor is toggle case type
" this_is_vim -> THIS_IS_VIM -> thisIsVim -> ThisIsVim -> this_is_vim

function! ToggleCase()
if has('perl')
perl <<EOF

  #word to word list
  sub split_words {
    my $word = shift;
    my @word = ();
    #snake
    if ($word =~ /_/g) {
      @words = map {lc($_)} split('_', $word);
    #maybe camel
    } else {
      $word =~ s/([A-Z])/_$1/g;
      $word =~ s/^_//g;
      @words = map {lc($_)} split('_', $word);
    }
    #map {VIM::Msg($_)} @words;
    return @words;
  }

  #to UPPER_SNAKE_CASE
  sub to_upper_snake_case {
    my @words = @_;
    return join('_', map {uc($_)} @words);
  }

  #to lower_snake_case
  sub to_lower_snake_case {
    my @words = @_;
    return join('_', map {lc($_)} @words);
  }

  #to UpperCamelCase
  sub to_upper_camel_case {
    my @words = @_;
    return join('', map {ucfirst($_)} @words);
  }

  #to lowerCamelCase
  sub to_lower_camel_case {
    my @words = @_;
    return lcfirst(join('', map {ucfirst($_)} @words));
  }

  #suppose what case
  sub suppose_case {
    my $word = shift;
    if ($word =~ /_[a-z]/g) {
      return 'lower_snake';
    } elsif ($word =~ /_[A-Z]/g) {
      return 'upper_snake';
    } elsif ($word =~ /^[a-z]+$/g) {
      return 'lower_word';
    } elsif ($word =~ /^[A-Z]+$/g) {
      return 'upper_word';
    } elsif ($word =~ /^[A-Z]/g) {
      return 'upper_camel';
    } elsif ($word =~ /^[a-z]/g) {
      return 'lower_camel';
    }
  }


  #my @pos = $curwin->Cursor();
  #my $row = @pos[0];
  #my $col = @pos[1];
  #my $line = $curbuf->Get($row);
  my $cursor_word = VIM::Eval('expand("<cword>")');
  my $current_case = suppose_case($cursor_word);
  my $result;
  my @words = split_words($cursor_word);

  if ($current_case eq 'lower_snake') {
    $result = to_upper_snake_case(@words);
  } elsif ($current_case eq 'upper_snake') {
    $result = to_lower_camel_case(@words);
  } elsif ($current_case eq 'lower_camel') {
    $result = to_upper_camel_case(@words);
  } elsif ($current_case eq 'upper_camel') {
    $result = to_lower_snake_case(@words);
  } elsif ($current_case eq 'lower_word') {
    $result = uc($cursor_word);
  } elsif ($current_case eq 'upper_word') {
    $result = lc($cursor_word);
  }

  if ($result) {
    my $replaced = VIM::Eval('substitute(getline("."), "' . $cursor_word . '", "' . $result . '", "g")');
    $replaced =~ s/"/\\"/g;
    VIM::Eval('setline(".", "' . $replaced . '")');
  }
EOF
endif
endfunction
