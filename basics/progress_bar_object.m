classdef progress_bar_object < handle
    properties
        n_
        percent_as_displayed_last_
        did_print_at_least_one_line_
        did_print_final_newline_
        tic_id_
    end
    
    methods
        function self = progress_bar_object(n)
            self.n_ = n ;
            self.percent_as_displayed_last_ = [] ;
            self.did_print_at_least_one_line_ = false ;
            self.did_print_final_newline_ = false ;
            self.tic_id_ = tic() ;
        end
        
        function update(self, i)
            n =self.n_ ;
            percent = fif(n==0, 100, 100*(i/n)) ;
            percent_as_displayed = round(percent*10)/10 ;    
            if ~isequal(percent_as_displayed, self.percent_as_displayed_last_) ,
                if self.did_print_at_least_one_line_ ,
                    delete_bar = repmat('\b', [1 1+50+1+2+4+1]) ;
                    fprintf(delete_bar) ;
                end
                bar = repmat('*', [round(percent/2) 1]) ;
                fprintf('[%-50s]: %4.1f%%', bar, percent_as_displayed) ;
                self.did_print_at_least_one_line_ = true ;
            end
            if i>=n ,
                fprintf('\n') ;
                self.did_print_final_newline_ = true ;
            end
            self.percent_as_displayed_last_ = percent_as_displayed ;
        end
        
        function finish_up(self)
            if ~self.did_print_final_newline_ ,
                fprintf('\n') ;
                self.did_print_final_newline_ = true ;
            end                
            toc(self.tic_id_) ;
        end
    end
end
