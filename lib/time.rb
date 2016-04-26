class Time
	def ww
		calculate_ww do |y, w|
			sprintf("%04d W%02d", y, w)
		end
	end

	def ww_nbr
		calculate_ww do |y, w|
	    sprintf("%04d%02d", y, w).to_i
		end    
	end

	def calculate_ww(&block)
		y = self.year
		w = self.strftime("%U").to_i
		w += 1 if Time.local(y, 1, 1).wday != 0
       
		if (self.yday + (6 - self.wday) > days_in_year)
			y += 1
			w = 1
		end
		
		yield(y, w) if block_given?
	end

	def week_of_year
		strftime("%U").to_i
	end
	
	def days_in_year
		Time.local(self.year, 12, 31).yday
	end
	
	def add_weeks(number_weeks)
		self.add_days(7 * number_weeks)
	end
	
	def add_days(number_days)
		self + (86400 * number_days)
	end
		
	def ticks
		(self - Time.local(self.year, self.month, self.day)).to_i
	end
end

